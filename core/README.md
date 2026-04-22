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

## Cost Optimization and Disaster Recovery

Disaster recovery (DR) readiness is validated through recurring drills rather than inferred from architecture diagrams or configuration reviews alone.

### DR Drill Matrix

Canonical runbooks and postmortem template for this matrix:

- `DB PITR restore`: [`docs/runbooks/db-pitr-restore.md`](../docs/runbooks/db-pitr-restore.md)
- `Zone loss failover`: [`docs/runbooks/zone-loss-failover.md`](../docs/runbooks/zone-loss-failover.md)
- `Queue replay`: [`docs/runbooks/queue-replay.md`](../docs/runbooks/queue-replay.md)
- `Cache cold-start`: [`docs/runbooks/cache-cold-start.md`](../docs/runbooks/cache-cold-start.md)
- `Webhook replay`: [`docs/runbooks/webhook-replay.md`](../docs/runbooks/webhook-replay.md)
- Postmortem template (mandatory): [`docs/postmortems/template.md`](../docs/postmortems/template.md)

| Scenario | Cadence | Objective metrics to capture | Pass/fail threshold | Escalation owner | Evidence retention |
| --- | --- | --- | --- | --- | --- |
| DB PITR restore | Monthly | Actual RTO, actual data-loss window | **Pass**: RTO <= 60 minutes and data-loss window <= 15 minutes. **Fail**: any breach or unrecoverable restore step. | Database Platform Owner | Runbook updates in `docs/runbooks/`, restore logs in centralized log storage, postmortem in `docs/postmortems/`. |
| Zone loss | Quarterly | Actual RTO, actual data-loss window | **Pass**: traffic failover and steady-state recovery within 30 minutes, no data-loss window > 5 minutes. **Fail**: manual intervention required outside documented procedure or threshold breach. | SRE On-call Lead | Failover runbook evidence in `docs/runbooks/`, incident timeline/logs in centralized log storage, postmortem in `docs/postmortems/`. |
| Queue replay | Monthly | Backlog recovery time, actual data-loss window | **Pass**: replay completes within 45 minutes with no lost acknowledged messages. **Fail**: replay exceeds threshold or message loss detected. | Messaging Platform Owner | Replay procedure and checkpoints in `docs/runbooks/`, consumer lag/replay logs in centralized log storage, postmortem in `docs/postmortems/`. |
| Cache cold-start | Quarterly | Actual RTO, backlog recovery time | **Pass**: p95 latency and error rate return to SLO-compliant range within 20 minutes. **Fail**: sustained SLO violation beyond 20 minutes. | Application Performance Owner | Cache warmup runbook in `docs/runbooks/`, latency/error telemetry in centralized log storage, postmortem in `docs/postmortems/`. |
| Webhook replay | Semiannual | Backlog recovery time, actual data-loss window | **Pass**: replay completes within 90 minutes with idempotent processing and no duplicate side effects beyond accepted threshold. **Fail**: non-idempotent side effects or threshold breach. | Integrations Owner | Replay and idempotency runbook in `docs/runbooks/`, delivery/retry logs in centralized log storage, postmortem in `docs/postmortems/`. |

**Reporting requirement:** all published RTO/RPO values must be measured from drill evidence artifacts (run records, logs, and postmortems), not from design intent.

**Enforcement rule:** each completed DR drill must reference one runbook in `docs/runbooks/` and one completed postmortem based on `docs/postmortems/template.md`; drills without both artifacts are non-compliant.
