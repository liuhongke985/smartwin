# Backup and Recovery Procedures

## Backup
- Backup project documentation and configuration daily.
- Keep weekly snapshots for at least 4 weeks.

## Recovery
1. Restore repository from latest valid backup.
2. Re-run Phase 1 smoke test (`tests/phase1-smoke-test.sh`).
3. Validate CI workflow status after restoration.
