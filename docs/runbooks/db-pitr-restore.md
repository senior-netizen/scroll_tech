# Runbook: DB PITR Restore Drill

## Scope
Validate point-in-time recovery (PITR) of the primary database and measure objective RTO/RPO against DR thresholds.

## Prerequisites
- Approved drill window and incident commander assigned.
- Access to backup/PITR tooling and destination restore environment.
- Target recovery timestamp (`T_recover`) explicitly documented.
- Application write traffic either paused or redirected for controlled restore validation.
- Observability dashboards/log access for DB health, restore job status, and app read/write errors.

## Exact execution steps
1. Declare drill start timestamp (`T0`) in the incident channel and ticket.
2. Capture current DB replication/backup status and latest recoverable timestamp.
3. Provision isolated restore target (same engine/version/parameter group as production).
4. Start PITR restore to `T_recover` and record restore job identifier.
5. Track restore progress every 5 minutes; log status and blockers.
6. Run data integrity checks:
   - schema migration version
   - critical row counts
   - sampled transaction consistency for the window around `T_recover`
7. Switch read-only validation workload to restored instance.
8. If validation passes, execute controlled cutover/failback simulation (without customer impact unless approved).
9. Record drill end timestamp (`T_end`) when restored environment is declared healthy.
10. Compute:
    - measured RTO = `T_end - T0`
    - measured RPO/data-loss window = `Latest committed prod timestamp before drill - T_recover`

## Rollback / abort criteria
Abort the drill and rollback to pre-drill state if any occur:
- Restore job irrecoverably fails after two retries.
- Integrity checks fail on critical entities.
- Validation indicates unrecoverable transaction gaps outside accepted RPO.
- Production risk increases (error budget burn, elevated latency, or operator safety concerns).

Rollback actions:
1. Stop cutover simulation and route all traffic to known-good primary.
2. Re-enable paused writes if previously paused.
3. Mark restored instance as quarantined and preserve for forensics.
4. Escalate to Database Platform Owner and open postmortem.

## Telemetry to capture
- Restore job start/end timestamps and duration.
- Recoverable timestamp at drill start.
- DB CPU/memory/storage IOPS during restore.
- Application DB error rate and query latency during validation.
- Integrity-check output (pass/fail and mismatch details).

## Evidence artifact locations
- Incident timeline: `centralized-log-storage://incidents/<drill-id>/timeline`
- Restore logs: `centralized-log-storage://db/<drill-id>/restore`
- Integrity reports: `centralized-log-storage://db/<drill-id>/integrity`
- Final summary + metrics: `docs/postmortems/template.md` (instantiate per drill in `docs/postmortems/`)
