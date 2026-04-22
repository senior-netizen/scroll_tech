# Runbook: Zone Loss Failover Drill

## Scope
Validate regional/zone redundancy by simulating zone loss and verifying service failover within DR targets.

## Prerequisites
- Fault-injection plan approved by SRE On-call Lead.
- Traffic routing and failover controls verified (DNS/LB/service mesh).
- Capacity headroom confirmed in surviving zone(s).
- Runbook operator, observer, and communications owner assigned.
- Dashboards for availability, latency, saturation, and error budget ready.

## Exact execution steps
1. Announce drill start (`T0`) and freeze non-essential deployments.
2. Record baseline service SLI metrics (availability, p95 latency, error rate).
3. Simulate zone loss (disable workloads or network path in target zone per platform control plane).
4. Confirm health checks fail in impacted zone and traffic drains from unhealthy endpoints.
5. Trigger/verify automated failover policy.
6. Validate all critical service paths in surviving zone(s):
   - auth/session
   - read/write data path
   - async jobs
7. Scale up surviving zone if saturation exceeds safe thresholds.
8. Observe until steady state is reached and SLO-compliant.
9. Record recovery complete timestamp (`T_end`).
10. Restore original topology and re-balance traffic.

## Rollback / abort criteria
Abort and rollback when:
- Global availability drops below minimum acceptable threshold.
- Surviving zone cannot absorb load after one emergency scale action.
- Control plane anomalies prevent deterministic traffic steering.

Rollback actions:
1. Re-enable disabled zone resources.
2. Force traffic back to known-good distribution policy.
3. Halt further injection and declare incident mode.
4. Escalate to SRE On-call Lead and start postmortem.

## Telemetry to capture
- Failover trigger time and routing convergence time.
- Availability, p95/p99 latency, and error rate throughout drill.
- CPU/memory/pod/node saturation in surviving zone(s).
- Queue depth/backlog created during transient instability.
- Manual intervention count and duration.

## Evidence artifact locations
- Incident timeline: `centralized-log-storage://incidents/<drill-id>/timeline`
- Routing/failover logs: `centralized-log-storage://network/<drill-id>/failover`
- Service telemetry exports: `centralized-log-storage://observability/<drill-id>/sli`
- Final summary + metrics: `docs/postmortems/template.md` (instantiate per drill in `docs/postmortems/`)
