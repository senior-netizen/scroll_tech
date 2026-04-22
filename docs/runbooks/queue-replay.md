# Runbook: Queue Replay Drill

## Scope
Validate safe replay of backlog messages and measure backlog recovery time without acknowledged message loss.

## Prerequisites
- Replay window and target topic/queue partitions defined.
- Consumer application supports idempotent processing.
- Checkpoint/snapshot of consumer offsets captured.
- Dead-letter queue (DLQ) policy and limits confirmed.
- Messaging Platform Owner on-call during drill.

## Exact execution steps
1. Declare drill start (`T0`) and record current lag/backlog depth.
2. Pause target consumers and snapshot offsets/checkpoints.
3. Inject/simulate backlog or select historical replay range.
4. Resume consumers in replay mode using controlled concurrency.
5. Monitor lag drain rate and processing error rate every 2 minutes.
6. Route poison messages to DLQ after configured retry threshold.
7. Validate idempotency by sampling duplicate-delivery cases.
8. Continue until lag reaches steady-state baseline.
9. Record replay complete timestamp (`T_end`).
10. Compare pre/post replay ledger to detect loss or divergence.

## Rollback / abort criteria
Abort when:
- Sustained consumer error rate exceeds operational threshold.
- Non-idempotent side effects are detected.
- Replay throughput stalls with no progress for 10+ minutes.

Rollback actions:
1. Pause replay consumers.
2. Restore consumer offsets to pre-drill snapshot.
3. Isolate affected downstream side effects for remediation.
4. Escalate to Messaging Platform Owner and open postmortem.

## Telemetry to capture
- Backlog depth and lag over time.
- Throughput (messages/sec) and success/error ratios.
- Retry counts, DLQ ingress rate, and redelivery count.
- End-to-end processing latency during replay.
- Data reconciliation output (lost/duplicated message checks).

## Evidence artifact locations
- Incident timeline: `centralized-log-storage://incidents/<drill-id>/timeline`
- Broker/consumer logs: `centralized-log-storage://messaging/<drill-id>/replay`
- Reconciliation reports: `centralized-log-storage://messaging/<drill-id>/reconciliation`
- Final summary + metrics: `docs/postmortems/template.md` (instantiate per drill in `docs/postmortems/`)
