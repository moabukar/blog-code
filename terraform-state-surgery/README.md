# Terraform State Surgery

Techniques for splitting, moving, and refactoring Terraform state without downtime.

📖 **Blog Post:** [Terraform State Surgery](https://moabukar.co.uk/blog/terraform-state-surgery)

## Overview

Practical techniques for breaking up monolithic Terraform state files, moving resources between states, and refactoring infrastructure safely.

## Files

```
.
├── scripts/
│   ├── state-migration.sh      # Single domain migration script
│   ├── full-migration.sh       # Complete multi-domain migration
│   └── backup-state.sh         # State backup utility
├── examples/
│   ├── moved-blocks.tf         # Using moved blocks (TF 1.1+)
│   ├── import-blocks.tf        # Using import blocks (TF 1.5+)
│   ├── removed-blocks.tf       # Using removed blocks (TF 1.7+)
│   └── remote-state.tf         # Cross-state references
└── migration-checklist.md      # Pre/post migration checklist
```

## Golden Rules

```bash
# 1. ALWAYS backup your state first
terraform state pull > state-backup-$(date +%Y%m%d-%H%M%S).json

# 2. ALWAYS run plan after any state change
terraform plan
# Must show: "No changes. Your infrastructure matches the configuration."

# 3. NEVER delete the backup until you've verified everything works
```

## Key Commands

```bash
# List all resources in state
terraform state list

# Move resource within same state
terraform state mv aws_instance.web aws_instance.application

# Move into a module
terraform state mv aws_instance.web module.compute.aws_instance.web

# Remove from state (keeps infrastructure)
terraform state rm aws_instance.old

# Import existing resource
terraform import aws_vpc.main vpc-0abc123
```

## Migration Pattern

1. **Backup** - Always backup state first
2. **Create new structure** - Set up new directories/backends
3. **Import** - Import resources into new state
4. **Verify** - `terraform plan` must show no changes
5. **Remove from old** - Remove resources from old state
6. **Verify again** - Both states should show no changes

## References

- [Terraform State Commands](https://developer.hashicorp.com/terraform/cli/commands/state)
- [Moved Blocks](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
- [Import Blocks](https://developer.hashicorp.com/terraform/language/import)
