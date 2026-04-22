# Runbook: Webhook Replay Drill

## Scope
Validate replay of webhook deliveries with idempotent downstream processing and bounded duplicate side effects.

## Prerequisites
- Replay range (`event_id` or time interval) and tenant scope approved.
- Webhook processor idempotency keys verified and audited.
- Destination endpoint rate limits and retry budget known.
- Dead-letter/remediation path for non-retriable events available.
- Integrations Owner present for go/no-go decisions.

## Exact execution steps
1. Announce drill start (`T0`) and capture pending delivery backlog.
2. Freeze schema/config changes for webhook producer/consumer.
3. Export candidate events for replay and validate dedupe keys.
4. Start replay workers with capped concurrency and retry policy.
5. Monitor delivery success, retry rate, and duplicate side effects.
6. Quarantine failing endpoints and continue replay for healthy endpoints.
7. Run reconciliation against downstream state for sampled tenants.
8. Continue until backlog is drained and duplicate rate is within accepted threshold.
9. Record replay complete timestamp (`T_end`).
10. Publish measured backlog recovery time and data-loss window.

## Rollback / abort criteria
Abort when:
- Non-idempotent side effects exceed accepted threshold.
- Downstream partner/API error rates breach contractual limits.
- Replay queue growth outpaces drain for sustained period.

Rollback actions:
1. Pause replay workers.
2. Revert to standard delivery scheduler.
3. Isolate problematic tenants/endpoints for manual remediation.
4. Escalate to Integrations Owner and open postmortem.

## Telemetry to capture
- Replay throughput, success/failure ratio, and retry counts.
- Duplicate detection count and side-effect reconciliation deltas.
- Partner endpoint latency/error metrics.
- Backlog depth trajectory and drain completion time.
- Idempotency key collision/miss statistics.

## Evidence artifact locations
- Incident timeline: `centralized-log-storage://incidents/<drill-id>/timeline`
- Delivery/retry logs: `centralized-log-storage://integrations/<drill-id>/webhooks`
- Reconciliation evidence: `centralized-log-storage://integrations/<drill-id>/reconciliation`
- Final summary + metrics: `docs/postmortems/template.md` (instantiate per drill in `docs/postmortems/`)
