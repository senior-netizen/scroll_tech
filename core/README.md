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

## Assumptions and Concurrency Model

- Each API replica maintains an isolated DB connection pool.
- Queue workers are horizontally scaled consumers that process idempotent jobs.
- Retry behavior assumes at-least-once delivery and idempotent downstream writes.
- Redis is used for ephemeral coordination/state with explicit TTL defaults.

### Capacity Workbook

Use this workbook before load tests and before increasing production concurrency limits.

#### 1) DB pooling model

Formula:

- `total_pool_size = api_replicas × pool_per_replica`
- Hard constraint: `total_pool_size <= (postgresql_max_connections - admin_headroom)`

Operational policy:

- Reserve admin headroom for migrations, psql sessions, observability agents, and failover operations.
- Keep `target_pool_usage <= 70%` during sustained peak to preserve burst handling.

#### 2) Worker sizing model

Formula:

- `required_workers ≈ ingress_rate × avg_job_time / target_utilization`

Where:

- `ingress_rate` is jobs/sec.
- `avg_job_time` is seconds/job.
- `target_utilization` is a bounded value (typically 0.60-0.75).

Backlog burn-down model (oldest-message-age SLO):

- `backlog_clear_time = backlog_depth / (effective_throughput - ingress_rate)`
- `effective_throughput = (workers / avg_job_time) × target_utilization`
- To meet SLO: `backlog_clear_time <= max_oldest_message_age_slo`

If `effective_throughput <= ingress_rate`, backlog age diverges and SLO breach is guaranteed.

#### 3) Redis memory model

Formula:

- `redis_required_bytes = estimated_bytes_per_key × key_count × overhead_factor`

Operational assumptions:

- `overhead_factor` should include allocator + metadata overhead (commonly `1.3-1.8`, choose conservatively).
- TTL-based churn must model concurrent live keys, not daily writes alone.
- Churn estimation:
  - `live_key_count ≈ write_rate_per_sec × ttl_seconds` (steady state)
  - Replace `key_count` with `max(observed_live_keys, modeled_live_key_count)` for capacity planning.

#### 4) Worked example: 10,000 active users

Assumptions (conservative):

- Peak API replicas: `8`
- Pool per replica: `20`
- PostgreSQL `max_connections`: `300`
- Admin headroom: `60`
- Queue ingress: `120 jobs/sec`
- Average job time: `0.18 sec/job`
- Worker target utilization: `0.65`
- Max oldest-message-age SLO: `120 sec`
- Immediate backlog event depth: `4,000 jobs`
- Redis per-key footprint (payload + metadata): `420 bytes`
- Redis write rate: `200 keys/sec`
- TTL: `900 sec` (15 min)
- Redis overhead factor: `1.5`

Calculations:

1. **DB pool sizing**
   - `total_pool_size = 8 × 20 = 160`
   - Hard limit = `300 - 60 = 240`
   - Result: `160 <= 240` (safe, with `80` connection margin).

2. **Worker baseline**
   - `required_workers ≈ 120 × 0.18 / 0.65 = 33.23`
   - Round up and add 25% safety margin:
     - `34 × 1.25 = 42.5`, choose `44 workers`.

3. **Backlog burn-down check (44 workers)**
   - `effective_throughput = (44 / 0.18) × 0.65 = 158.89 jobs/sec`
   - Net drain rate = `158.89 - 120 = 38.89 jobs/sec`
   - `backlog_clear_time = 4,000 / 38.89 = 102.85 sec`
   - Result: `102.85 sec <= 120 sec` SLO (passes with ~17 sec margin).

4. **Redis memory sizing**
   - Modeled live keys from TTL churn:
     - `live_key_count ≈ 200 × 900 = 180,000`
   - `redis_required_bytes = 420 × 180,000 × 1.5 = 113,400,000 bytes`
   - Approximate memory = `108.1 MiB`
   - Add 30% safety margin for fragmentation and traffic bursts:
     - `108.1 × 1.3 ≈ 140.5 MiB` planned minimum.

Recommended production guardrails for this profile:

- Alert if DB pool usage > 75% for 5 minutes.
- Alert if oldest message age > 90 seconds (early warning before 120-second SLO).
- Keep Redis max memory policy explicit (`noeviction` for critical coordination keys).
- Re-run workbook whenever active users or per-user write rates change by >20%.
