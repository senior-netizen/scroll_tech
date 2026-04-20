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
