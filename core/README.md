# Offline-first local storage and sync architecture

## Local persistence

The local storage layer is implemented in `storage/sqlite_local_store.dart` with explicit tables:

- `products`
- `variants`
- `orders`
- `pending_sync_queue`

Orders are persisted with `pending_sync = 1` first, then corresponding queue operations are inserted in `pending_sync_queue`.

## Read-through cache (catalog browsing)

`repositories/catalog_repository.dart` serves cached rows from local storage immediately, then attempts remote refresh and upserts deltas.

## Local-first order submission

`repositories/order_repository.dart` writes order data locally, generates a client idempotency token (`client_token` UUID), and enqueues a `submitOrder` operation.

## Sync and retry strategy

`sync/sync_service.dart`:

1. Subscribes to connectivity status changes.
2. Flushes due queue operations when connectivity is online.
3. Submits orders using `client_token` idempotency.
4. Handles:
   - success: mark order synced + delete queue item
   - conflict: treat as idempotent success
   - transient failure: exponential backoff + jitter and retry

Queue processing is guarded with single-flight (`_isFlushing`) to avoid concurrent flush races.

## Transactional Integrity and Offline Reliability

The system relies on explicit invariants that must hold across local persistence, sync, and remote confirmation workflows.

### Invariants

| Invariant (strict form) | Enforcement layer | Failure handling | Verification method |
| --- | --- | --- | --- |
| `∀ variant_id: available_stock >= 0` | DB constraint (`CHECK (available_stock >= 0)`) + transaction logic in stock decrement path | Reject write if constraint fails; retry only after upstream reconciliation updates stock baseline | Integration test: concurrent reservation/order writes cannot produce negative stock |
| `reservation.expires_at > reservation.created_at ∧ now > expires_at => reservation.state = EXPIRED ∧ reserved_qty = 0` | Transaction logic on reservation consume path + background reconciler for stale reservations | Reject consume on expired reservation; reconciler marks expired and restores stock | Periodic audit query: find reservations past `expires_at` still marked active |
| `createOrderIntent(client_token, cart_hash)` is idempotent: repeated requests with same `client_token` return same `order_intent_id` and no duplicate side effects | DB uniqueness constraint on `client_token` + API validator + transaction logic for upsert/return-existing | Reject conflicting payload for same token; return existing intent for exact replay; retry safe on network timeout | Unit test: duplicate intent creation with same token yields identical intent id and single persisted row |
| `order_state` transitions are monotonic: `state_{n+1} ∈ AllowedSuccessors(state_n)` and never regresses | Transaction logic in order state transition service + API validator | Reject invalid transition; alert on detected regression from external callback/source | Integration test: invalid backward transition (`CONFIRMED -> PENDING`) is rejected |
| Payment confirmation source-of-truth is unique: `order.payment_confirmed = true` only when verified provider event/receipt exists in canonical payments table | DB constraint/foreign-key to canonical payment record + transaction logic in payment finalization + background reconciler for mismatches | Reject local/manual confirmation writes; reconcile divergent rows; alert on missing/duplicate provider confirmations | Periodic audit query: confirmed orders without canonical payment evidence must be zero |
