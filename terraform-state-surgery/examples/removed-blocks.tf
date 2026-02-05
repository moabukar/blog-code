# Removed blocks (Terraform 1.7+)
# Remove resources from state without destroying them

# Example 1: Remove from state, keep infrastructure
removed {
  from = aws_instance.legacy_server

  lifecycle {
    destroy = false
  }
}

# Example 2: Remove a module from state
removed {
  from = module.legacy_app

  lifecycle {
    destroy = false
  }
}

# Example 3: Remove indexed resource
removed {
  from = aws_subnet.old[0]

  lifecycle {
    destroy = false
  }
}

# Use cases:
# - Handing off resources to another team
# - Removing resources that will be managed manually
# - Migrating to a different IaC tool
# - Splitting resources to another state file

# Important: After applying, the resource still exists in AWS
# but Terraform no longer manages it
