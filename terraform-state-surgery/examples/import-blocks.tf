# Import blocks (Terraform 1.5+)
# Define imports in configuration instead of CLI commands

# Example 1: Import a VPC
import {
  to = aws_vpc.main
  id = "vpc-0abc123def456"
}

# Example 2: Import subnets
import {
  to = aws_subnet.private[0]
  id = "subnet-0abc123"
}

import {
  to = aws_subnet.private[1]
  id = "subnet-0def456"
}

# Example 3: Import into a module
import {
  to = module.networking.aws_vpc.main
  id = "vpc-0abc123def456"
}

# Example 4: Import with for_each key
import {
  to = aws_subnet.private["eu-west-1a"]
  id = "subnet-0abc123"
}

# Example 5: Import RDS instance
import {
  to = aws_db_instance.main
  id = "my-database-instance"
}

# Example 6: Import security group
import {
  to = aws_security_group.web
  id = "sg-0abc123def"
}

# After running terraform apply, these resources will be imported
# You can then remove the import blocks

# Generate configuration from imports (Terraform 1.5+):
# terraform plan -generate-config-out=generated.tf
