# Terraform Migration Checklist

## Pre-Migration

- [ ] Backup state file: `terraform state pull > state-backup-$(date +%Y%m%d).json`
- [ ] Document current Terraform version
- [ ] Document current provider versions
- [ ] Run `terraform plan` - confirm no changes
- [ ] Commit all code changes

## Per Version Upgrade

- [ ] Install new Terraform version
- [ ] Run upgrade tool if available (0.12upgrade, 0.13upgrade)
- [ ] Run `terraform init -upgrade`
- [ ] Run `terraform plan`
- [ ] Verify: "No changes"
- [ ] Commit changes with version in message

## S3 Migration (Provider 3.x → 4.x)

- [ ] Update code to use separate resources
- [ ] Run import script for all buckets
- [ ] Run `terraform plan` - verify no changes
- [ ] Test in dev/staging first
- [ ] Commit and document

## Post-Migration

- [ ] Update CI/CD pipelines with new Terraform version
- [ ] Update documentation
- [ ] Train team on new syntax/features
- [ ] Remove old Terraform binaries

## Upgrade Path

```
0.11 → 0.12 → 0.13 → 0.14 → 0.15 → 1.0 → 1.1+ → 1.11
```

## Timeline Estimate (200 resources)

| Phase | Duration | Notes |
|-------|----------|-------|
| 0.11 → 0.12 | 2 days | Most syntax changes |
| 0.12 → 0.13 | 4 hours | Mostly automated |
| 0.13 → 0.14 | 2 hours | Lock file setup |
| 0.14 → 0.15 | 2 hours | Deprecation fixes |
| 0.15 → 1.0 | 1 hour | Smooth |
| 1.0 → 1.5 (S3) | 3 days | S3 bucket split |
| 1.5 → 1.11 | 4 hours | Incremental |
| **Total** | **~1 week** | |
