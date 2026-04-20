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

## Security

### Payment Proof Upload Threat Model

#### Threats

- **MIME spoofing:** attackers upload executable or active payloads with falsified `Content-Type` values.
- **Large-file abuse:** oversized uploads attempt to exhaust bandwidth, storage, or scanning workers.
- **Replay:** previously valid upload authorizations are reused to attach stale/forged payment proof.
- **Unauthorized object overwrite:** users attempt key collision or path traversal to replace another order's proof.
- **Malicious content:** uploaded files embed malware, phishing lures, or weaponized document payloads.

#### Controls

- **Strict signed URL conditions:** signed upload policies enforce `content-length-range`, an allowlist of MIME types, and an order-scoped key prefix that cannot be escaped.
- **One-time upload tokens:** upload intents are minted as single-use tokens cryptographically bound to `order_id` + `user_id` and expire quickly.
- **Server-side metadata verification:** before state transitions (for example, `awaiting_verification` → `proof_received`), backend verifies object key, size, MIME, checksum/ETag, and token linkage.
- **Asynchronous malware scanning + quarantine:** all new objects enter a quarantine state, are scanned out-of-band, and only promoted to a trusted prefix after a clean verdict.
- **Deny-public storage + least privilege IAM:** bucket policies deny any public ACL/policy path; principals get minimal actions scoped to exact prefixes and required operations.

#### Detection

- Alert on abnormal upload size distributions and per-user/per-order upload rate spikes.
- Alert on repeated signed URL/token signature validation failures (possible brute force or replay probing).

#### Recovery

- Quarantine and re-verification flow: suspicious or newly-indicated-malicious objects are re-quarantined, rescanned with updated signatures, and detached from order state until cleared.
- Manual review escalation path: route unresolved detections to operations/fraud reviewers with order timeline, uploader identity, metadata, and scan telemetry for explicit disposition.
