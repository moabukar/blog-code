# Terraform 0.11 to 1.11 Migration

Scripts and examples for migrating Terraform from 0.11 through to modern versions.

📖 **Blog Post:** [Terraform 0.11 to 1.11 Migration - The Full Journey](https://moabukar.co.uk/blog/terraform-0.11-to-1.11-migration)

## Contents

```
terraform-migration/
├── scripts/
│   ├── upgrade-0.12.sh           # 0.11 → 0.12 upgrade
│   ├── upgrade-0.13.sh           # 0.12 → 0.13 upgrade
│   └── s3-migration-import.sh    # AWS Provider 3.x → 4.x S3 imports
├── examples/
│   ├── versions.tf               # Required providers template
│   ├── syntax-comparison.tf      # 0.11 vs 0.12+ syntax
│   └── s3-bucket-old-vs-new.tf   # S3 bucket split example
├── migration-checklist.md        # Pre/post migration checklist
└── README.md
```

## Upgrade Path

You can't jump directly from 0.11 to 1.x:

```
0.11 → 0.12 → 0.13 → 0.14 → 0.15 → 1.0 → 1.x
```

## The Golden Rule

**After each upgrade, `terraform plan` must show no changes.**

## Quick Start

### 0.11 to 0.12 (HCL2 Migration)

```bash
# Backup state
terraform state pull > backup.json

# Run upgrade tool
terraform-0.12 0.12upgrade

# Review changes
git diff

# Verify
terraform-0.12 init
terraform-0.12 plan  # Must show no changes
```

### 0.12 to 0.13 (Provider Requirements)

```bash
# Run upgrade
terraform-0.13 0.13upgrade

# Add required_providers block to versions.tf

# Reinitialize
terraform-0.13 init -upgrade
terraform-0.13 plan  # Must show no changes
```

### 0.13+ to 1.x

From 0.14 onwards, upgrades are mostly straightforward:

```bash
terraform init -upgrade
terraform plan  # Verify no changes
```

## Key Syntax Changes (0.11 → 0.12)

| Feature | 0.11 | 0.12+ |
|---------|------|-------|
| Variable reference | `"${var.name}"` | `var.name` |
| Type constraint | `type = "string"` | `type = string` |
| List access | `"${element(list, 0)}"` | `list[0]` |
| Conditionals | `"${var.x ? 1 : 0}"` | `var.x ? 1 : 0` |

## Common Issues

1. **State version incompatibility** - Backup before each upgrade
2. **Provider version changes** - Pin provider versions
3. **count/for_each on modules** - Only available from 0.13+
4. **Sensitive values** - New in 0.14+

## License

MIT
