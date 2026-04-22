# Runbook: Cache Cold-Start Drill

## Scope
Validate system behavior when cache is empty/cold and verify return to SLO-compliant steady state within target recovery window.

## Prerequisites
- Cache tier topology and flush scope documented.
- Origin datastore capacity validated for anticipated read amplification.
- Cache warmup strategy and rate limits preconfigured.
- Application Performance Owner and database observer assigned.
- Dashboards for p95 latency, error rate, cache hit ratio, and origin load prepared.

## Exact execution steps
1. Announce drill start (`T0`) and record baseline SLIs.
2. Disable conflicting deploys/autoscaling experiments.
3. Evict cache keys (full or namespace-scoped based on drill plan).
4. Enable staged warmup workers with capped QPS.
5. Monitor hit ratio recovery and origin datastore stress signals.
6. If latency/error budget risk rises, reduce warmup concurrency.
7. Validate critical user flows under cold-start conditions.
8. Continue until p95 latency and error rate are back within SLO bounds.
9. Record recovery complete timestamp (`T_end`).
10. Return warmup settings to baseline and close drill.

## Rollback / abort criteria
Abort when:
- Origin datastore saturation threatens stability.
- Error rate crosses incident threshold for sustained period.
- Critical user flows fail with no immediate mitigation.

Rollback actions:
1. Stop warmup workers.
2. Apply emergency cache prefill for critical keyspaces.
3. Throttle non-critical read traffic.
4. Escalate to Application Performance Owner and open postmortem.

## Telemetry to capture
- Cache hit ratio over time and keyspace-level distribution.
- Application p95/p99 latency and error rate.
- Origin datastore QPS, latency, and saturation metrics.
- Warmup worker throughput and queue depth.
- Time to SLO re-attainment (backlog recovery time).

## Evidence artifact locations
- Incident timeline: `centralized-log-storage://incidents/<drill-id>/timeline`
- Cache/warmup logs: `centralized-log-storage://cache/<drill-id>/warmup`
- SLI exports: `centralized-log-storage://observability/<drill-id>/sli`
- Final summary + metrics: `docs/postmortems/template.md` (instantiate per drill in `docs/postmortems/`)
