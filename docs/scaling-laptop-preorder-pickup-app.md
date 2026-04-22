# Scaling a Laptop Pre-Order and Pickup App Beyond 10,000 Concurrent Users

> **Document control**
>
> - **Version:** 2.0.0
> - **Last updated:** 2026-04-21
> - **Owner:** Architecture Team
> - **Status:** Approved for implementation planning

---

## 1) Problem analysis

### 1.1 Business context and goal
This document is the **single source of truth** for the target architecture and scaling plan of the laptop pre-order and pickup platform. It defines the production design required to sustain **>10,000 concurrent active users** during launch spikes while preserving checkout integrity, pickup-slot correctness, and low-latency user experience.

### 1.2 Non-negotiable constraints
- Inventory is finite and highly contested during launch windows.
- Overselling is unacceptable; reservation correctness is a hard requirement.
- Mobile network quality is variable; client retries and reconnects are expected.
- Traffic is bursty (campaign drops, email blasts, influencer referrals).
- Regional outages must not cause complete business stoppage.
- PII and payment-adjacent flows require strong security controls and auditability.

### 1.3 Target scale and reliability objectives
- **Concurrency target:** 10,000+ active sessions, with short bursts to 20,000.
- **Read-heavy profile:** product discovery and availability checks dominate.
- **Write-sensitive profile:** reservation creation, payment authorization, pickup confirmation.
- **Availability objective:** 99.95% monthly for customer-critical APIs.
- **Data correctness objective:** 0 oversell incidents attributable to race conditions.

---

## 2) System design

## 2.1 System architecture

### 2.1.1 Logical architecture
1. **Clients**: Web SPA + mobile apps.
2. **Edge layer**: CDN + WAF + API Gateway + rate limiting.
3. **Application services** (stateless):
   - Catalog Service
   - Inventory Service
   - Reservation Service
   - Checkout/Order Service
   - Pickup Scheduling Service
   - Notification Service
   - Identity/Profile Service
4. **Data layer**:
   - Relational OLTP database (authoritative transactional state)
   - Redis cluster (cache + distributed locks + token buckets)
   - Object store (artifacts, reports)
5. **Async/event layer**:
   - Durable message queue / event bus
   - Background workers for side effects (notifications, reconciliation, analytics)
6. **Observability and control plane**:
   - Centralized logs, metrics, traces
   - Alerting and SLO dashboards
   - Deployment orchestration and feature flags

### 2.1.2 Deployment topology
- **Active-active multi-AZ** within a primary region for all stateless services.
- **Warm standby secondary region** with replicated data and traffic failover runbook.
- Services run in autoscaled containers (or equivalent orchestration).
- All APIs terminate TLS at the edge; internal traffic is mTLS between services.

## 2.2 Module/service decomposition

### 2.2.1 Catalog Service (read-heavy)
- Serves product metadata, pricing, and compatibility attributes.
- Maintains read replicas / cache-first query paths.
- Strictly no inventory mutation logic.

### 2.2.2 Inventory Service (consistency-critical)
- Owns stock ledgers: `on_hand`, `reserved`, `committed`.
- Exposes atomic reserve/release/commit operations.
- Implements optimistic concurrency with version checks.

### 2.2.3 Reservation Service
- Creates short-lived reservation holds (TTL based).
- Extends/revokes holds under policy.
- Enforces idempotency tokens for client retries.

### 2.2.4 Checkout/Order Service
- Finalizes reservation into confirmed order.
- Coordinates payment authorization and order persistence.
- Emits `OrderConfirmed` events for downstream consumers.

### 2.2.5 Pickup Scheduling Service
- Owns slot capacity per location/time window.
- Allocates slot atomically during checkout.
- Supports rescheduling with conflict-safe updates.

### 2.2.6 Notification Service
- Consumes order/pickup events.
- Sends email/SMS/push asynchronously.
- Retries transient failures with dead-letter queue fallback.

### 2.2.7 Identity/Profile Service
- Handles user authn integration, profile lookup, and preferences.
- Issues scoped claims for downstream authz checks.

## 2.3 Data flow

### 2.3.1 Happy path (pre-order to pickup)
1. Client fetches catalog (CDN/cache-backed).
2. Client requests live availability (Inventory Service).
3. Client creates reservation hold (`POST /reservations`).
4. Client proceeds to checkout (`POST /orders`) using reservation + idempotency key.
5. Checkout confirms payment + pickup slot.
6. Order commit triggers events.
7. Workers send confirmation notification and update analytics.

### 2.3.2 Contention path
- Concurrent users request same SKU.
- Inventory Service serializes write conflicts via row-version checks.
- Failed compare-and-swap returns deterministic `409 CONFLICT_INVENTORY_VERSION`.
- Client retries with jittered backoff, or UI prompts out-of-stock alternatives.

### 2.3.3 Reservation expiry path
- Reservation TTL expiration emits `ReservationExpired`.
- Worker releases stock and slot hold idempotently.
- Cache invalidation event refreshes availability projections.

## 2.4 API contracts

### 2.4.1 Design principles
- Versioned REST contracts (`/v1/...`).
- Strict schema validation at gateway and service boundaries.
- Correlation IDs on all requests (`X-Request-Id`).
- Idempotency key required on mutation endpoints (`Idempotency-Key`).

### 2.4.2 Core APIs (illustrative)
- `GET /v1/catalog?category=laptops&page=1`
  - 200: paginated product list.
- `GET /v1/inventory/{sku}/availability?store_id=...`
  - 200: `{available_units, next_restock_eta}`.
- `POST /v1/reservations`
  - Body: `{sku, qty, store_id, user_id}`.
  - 201: `{reservation_id, expires_at}`.
  - 409: insufficient or stale availability.
- `POST /v1/orders`
  - Headers: `Idempotency-Key`.
  - Body: `{reservation_id, payment_intent_id, pickup_slot_id}`.
  - 201: `{order_id, status}`.
- `POST /v1/pickups/{order_id}/check-in`
  - 200: pickup initiation state.

### 2.4.3 Error model
Standard envelope:
```json
{
  "error_code": "INVENTORY_CONFLICT",
  "message": "Reservation cannot be fulfilled with current stock.",
  "request_id": "req_123",
  "retryable": true
}
```

## 2.5 Storage model

### 2.5.1 Relational schema (authoritative)
- `products(id, sku, name, attrs_json, price_cents, updated_at)`
- `inventory_ledger(sku, location_id, on_hand, reserved, committed, version, updated_at)`
- `reservations(id, user_id, sku, qty, location_id, status, expires_at, idempotency_key, created_at)`
- `orders(id, user_id, reservation_id, pickup_slot_id, status, payment_ref, created_at)`
- `pickup_slots(id, location_id, window_start, window_end, capacity_total, capacity_used, version)`
- `outbox_events(id, aggregate_type, aggregate_id, event_type, payload_json, published_at, retry_count)`

### 2.5.2 Data consistency decisions
- Strong consistency for inventory, reservations, orders, and pickup capacity.
- Eventual consistency acceptable for catalog projections and analytics.
- Outbox pattern guarantees transactional event emission after state change.

### 2.5.3 Data retention
- Hot transactional data retained in OLTP per policy.
- Audit/security events retained 13 months minimum.
- PII minimization: only required fields stored; tokenized where feasible.

## 2.6 Caching plan

### 2.6.1 Cache tiers
- **Edge CDN:** static assets, product images, cacheable catalog pages.
- **Service-level Redis:** inventory snapshot reads, pickup slot summaries.
- **Client-side cache:** short-lived availability responses with ETags.

### 2.6.2 TTL strategy
- Catalog metadata: 5–15 minutes with event-driven invalidation.
- Availability snapshots: 2–5 seconds max (stale-safe read optimization).
- User profile preferences: 5 minutes.

### 2.6.3 Cache correctness guardrails
- Mutations always hit source of truth DB first.
- Write-through or explicit invalidation on reservation/order commits.
- Cache stampede prevention using request coalescing and jittered TTLs.

## 2.7 Queueing and asynchronous workflows

### 2.7.1 Event taxonomy
- Domain events: `ReservationCreated`, `ReservationExpired`, `OrderConfirmed`, `PickupScheduled`.
- Operational events: `NotificationFailed`, `DLQThresholdExceeded`.

### 2.7.2 Queueing model
- At-least-once delivery with consumer idempotency.
- Per-topic partitioning by stable key (e.g., `order_id`, `sku`) to preserve ordering where needed.
- Dead-letter queues for poison messages with replay tooling.

### 2.7.3 Worker controls
- Exponential backoff with capped retries.
- Visibility timeout tuned to 99th percentile processing time.
- Circuit breaker around third-party notification providers.

## 2.8 Idempotency strategy

### 2.8.1 API idempotency
- All mutation endpoints require client-supplied `Idempotency-Key`.
- Key scope: `(tenant/user, route, request_hash)`.
- Idempotency records stored with response snapshot + TTL (24h default).

### 2.8.2 Event idempotency
- Consumers persist processed event IDs in dedupe store.
- Handlers designed as upserts/compare-and-swap, never blind inserts.

### 2.8.3 Operational guarantees
- Duplicate client retries do not create duplicate orders.
- Duplicate event deliveries do not trigger duplicate side effects.

## 2.9 Observability (logs, metrics, traces, alerts)

### 2.9.1 Logging
- Structured JSON logs with fields: `timestamp`, `level`, `service`, `request_id`, `user_id_hash`, `error_code`.
- Redaction pipeline for PII/secrets before sink export.

### 2.9.2 Metrics
- RED metrics per API (Rate, Errors, Duration).
- Resource metrics: CPU, memory, DB connections, queue lag.
- Business metrics: reservation success %, oversell count, pickup no-show rate.

### 2.9.3 Tracing
- Distributed tracing with W3C trace context across edge, API, DB, and workers.
- Tail-based sampling prioritizing errors and high-latency spans.

### 2.9.4 Alerting
- Multi-window burn-rate alerts for SLO violations.
- Critical alerts:
  - Inventory conflict spike above threshold.
  - Queue lag > configured max for 5 minutes.
  - Checkout p95 latency breach sustained 10 minutes.

## 2.10 Reliability and resilience controls

### 2.10.1 Failure modes and mitigations
- **DB primary failover:** automatic leader election + connection retry.
- **Cache cluster degradation:** fallback to DB reads with adaptive rate limiting.
- **Queue outage:** transactional outbox buffering until broker recovery.
- **Third-party provider failure:** circuit break + deferred retry + provider failover.

### 2.10.2 Retry/backoff/circuit breaking
- Client and server retries use exponential backoff + full jitter.
- No retries for deterministic 4xx validation errors.
- Circuit breaker states (closed/open/half-open) instrumented and alertable.

### 2.10.3 DR strategy and measurable targets
- **RTO:** 30 minutes for regional failover.
- **RPO:** ≤ 5 minutes for transactional data.
- Quarterly game-day tests for failover runbooks.
- Immutable backups + periodic restore verification.

### 2.10.4 SLO/SLA targets
- **Checkout API availability SLO:** 99.95% monthly.
- **Checkout latency SLO:** p95 ≤ 350 ms, p99 ≤ 800 ms.
- **Inventory reserve success SLO under in-stock conditions:** ≥ 99.9%.
- **Customer-facing SLA:** 99.9% monthly availability.

## 2.11 Security controls

### 2.11.1 Authn/authz
- OIDC/OAuth2 for end-user authentication.
- Short-lived JWT access tokens; refresh token rotation.
- Fine-grained RBAC/ABAC for admin and operations endpoints.

### 2.11.2 Input validation and abuse prevention
- JSON schema validation on every API boundary.
- Server-side canonicalization and strict type checks.
- WAF rules + per-IP/per-user rate limits + bot detection.

### 2.11.3 Secrets handling
- Secrets stored in managed secret vault; never in code or logs.
- Automatic key rotation and envelope encryption via KMS.
- Runtime secret fetch with least-privilege IAM roles.

### 2.11.4 Data protection
- TLS 1.2+ in transit; AES-256 encryption at rest.
- Audit trail for privileged operations.
- Pseudonymized user identifiers in observability tooling.

---

## 3) Implementation

## 3.1 Capacity planning assumptions

### 3.1.1 Traffic assumptions (steady-state launch window)
- 10,000 concurrent active users.
- 2.0 requests/user/min average across active sessions.
- **Baseline ingress:** ~333 RPS.
- **Burst factor:** 3x for launch spikes.
- **Peak design point:** **1,000 RPS** sustained for 10 minutes.

### 3.1.2 Endpoint mix at peak (1,000 RPS)
- Catalog reads: 45% (450 RPS)
- Availability checks: 30% (300 RPS)
- Reservation create/update: 15% (150 RPS)
- Checkout/order creation: 8% (80 RPS)
- Pickup/check-in/other writes: 2% (20 RPS)

### 3.1.3 Latency and throughput budgets
- Edge + gateway budget: 40 ms p95
- Service compute budget: 120 ms p95
- DB roundtrip budget (writes): 120 ms p95
- Buffer: 70 ms
- End-to-end checkout target: ≤ 350 ms p95

### 3.1.4 Database capacity model
At peak:
- Read QPS ~1,800 (before cache), target 70% cache offload → net DB read QPS ~540.
- Write QPS ~250 (reservations/orders/slots/ledger).
- Total modeled DB QPS: ~790 with 40% headroom target.
- Connection pool sizing per service based on max in-flight writes and DB limits.

### 3.1.5 Queue depth model
- Event emission: ~120 events/sec at peak checkout + reservation churn.
- Worker drain target: >150 events/sec sustained.
- Maximum acceptable lag: <60 seconds p95.
- Alert threshold: depth exceeds 9,000 messages for >5 minutes.

## 3.2 Horizontal scaling plan

### 3.2.1 Stateless services
- Minimum replica count per critical service: 3 across AZs.
- HPA target on CPU + request concurrency + p95 latency.
- Pre-scale before known launches using scheduled autoscaling.

### 3.2.2 Data tier
- Primary DB with multi-AZ synchronous replica.
- Read replicas for catalog/reporting queries.
- Partition strategy for high-cardinality ledgers by `(sku, location)` or time window as needed.

### 3.2.3 Cache and queue tier
- Redis cluster sharding enabled before 70% memory utilization.
- Queue partitions scaled with consumer group concurrency to keep lag <60s.

## 3.3 Staged load testing and rollout criteria

### 3.3.1 Stage A: baseline functional load
- Target: 300 RPS mixed traffic for 30 min.
- Exit criteria:
  - Error rate <0.5%
  - Checkout p95 <350 ms
  - No oversell events

### 3.3.2 Stage B: expected peak validation
- Target: 1,000 RPS for 60 min.
- Exit criteria:
  - Error rate <1.0%
  - Checkout p95 <350 ms, p99 <800 ms
  - Queue lag p95 <60 s
  - DB CPU <70%

### 3.3.3 Stage C: stress and failure injection
- Target: 1,500 RPS + induced dependency faults.
- Fault scenarios:
  - Cache node loss
  - One AZ service disruption
  - Notification provider outage
- Exit criteria:
  - Core ordering path remains available
  - Graceful degradation observed
  - Recovery to SLO band within 15 minutes

### 3.3.4 Stage D: canary rollout
- 5% → 25% → 50% → 100% traffic progression.
- Promotion gates at each stage:
  - SLO burn rate within budget
  - No critical alerts for 30 minutes
  - Business KPIs stable (conversion, reservation success)

---

## 4) Edge cases

- **Double-submit from client refresh:** deduped via idempotency key.
- **Payment succeeds but order write times out:** reconciliation job finalizes from payment reference.
- **Reservation expires during checkout:** deterministic failure with re-reserve prompt.
- **Clock skew across services:** all TTL and expiration checks based on server monotonic time/reference service.
- **Store capacity updates during active bookings:** versioned slot records prevent overbooking.
- **Replay of stale tokens:** rejected by token expiry + nonce/replay protections where applicable.

---

## 5) Improvements roadmap

### 5.1 Near-term (0-3 months)
- Adopt adaptive concurrency limits per endpoint.
- Add synthetic user journeys for continuous SLO validation.
- Implement automated DLQ replay with policy checks.

### 5.2 Mid-term (3-6 months)
- Introduce regional active-active writes for reservations with deterministic conflict resolution.
- Add predictive autoscaling based on campaign calendar and traffic forecasting.

### 5.3 Long-term (6-12 months)
- Evaluate event-sourced inventory ledger for richer audit and replay semantics.
- Extend pickup optimization using demand forecasting and slot price incentives.

---

## Appendix A: Decision log (initial)
- **D-001:** Prefer modular services over a single monolith due to contention isolation requirements.
- **D-002:** Inventory and pickup capacity remain strongly consistent in relational store.
- **D-003:** Async side effects must use outbox + queue to protect checkout latency.
- **D-004:** Idempotency is mandatory for all write APIs and async consumers.
