# Terraform State Migration Checklist

## Pre-Migration

- [ ] Backup all state files
- [ ] Document current resource count per state
- [ ] Map dependencies between resources
- [ ] Plan the new state structure
- [ ] Disable CI/CD auto-applies
- [ ] Notify team of migration window
- [ ] Ensure no active applies in progress

## Per-Domain Migration

- [ ] Create new directory structure
- [ ] Copy resource code to new location
- [ ] Add remote_state data sources where needed
- [ ] Add outputs for cross-state references
- [ ] Run `terraform init` in new directory
- [ ] Import resources into new state
- [ ] Verify: `terraform plan` shows no changes
- [ ] Remove resources from old state
- [ ] Verify: old state `terraform plan` shows no changes
- [ ] Commit changes

## Post-Migration

- [ ] Update CI/CD pipelines for new structure
- [ ] Update documentation
- [ ] Re-enable CI/CD auto-applies
- [ ] Delete old monolithic state (after grace period)
- [ ] Archive backup files securely
- [ ] Update runbooks and incident procedures
- [ ] Notify team migration is complete

## Verification Commands

```bash
# Count resources in state
terraform state list | wc -l

# Verify no changes needed
terraform plan -detailed-exitcode
# Exit code 0 = no changes (good!)
# Exit code 2 = changes detected (investigate!)

# Compare resource counts before/after
diff <(terraform state list | sort) <(cat backup.json | jq -r '.resources[].instances[].attributes.id' | sort)
```

## Rollback Procedure

If something goes wrong:

```bash
# 1. Stop all applies immediately
# 2. Restore state from backup
terraform state push backup-TIMESTAMP.json

# 3. Verify
terraform plan
# Should show no changes

# 4. Investigate what went wrong before retrying
```
