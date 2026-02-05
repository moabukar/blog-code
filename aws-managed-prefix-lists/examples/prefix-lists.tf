# prefix-lists.tf
# Customer-managed prefix lists for corporate networks

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

# Corporate offices prefix list
resource "aws_ec2_managed_prefix_list" "corporate_offices" {
  name           = "corporate-offices"
  address_family = "IPv4"
  max_entries    = 20

  entry {
    cidr        = "203.0.113.0/24"
    description = "London HQ"
  }

  entry {
    cidr        = "198.51.100.0/24"
    description = "New York office"
  }

  entry {
    cidr        = "192.0.2.0/24"
    description = "Singapore office"
  }

  tags = {
    Name        = "corporate-offices"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Data centres prefix list
resource "aws_ec2_managed_prefix_list" "datacentres" {
  name           = "on-premises-datacentres"
  address_family = "IPv4"
  max_entries    = 50

  entry {
    cidr        = "10.100.0.0/16"
    description = "DC1 - London"
  }

  entry {
    cidr        = "10.200.0.0/16"
    description = "DC2 - Frankfurt"
  }

  entry {
    cidr        = "10.150.0.0/16"
    description = "DR Site - Dublin"
  }

  tags = {
    Name        = "on-premises-datacentres"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Partners/vendors prefix list
resource "aws_ec2_managed_prefix_list" "partners" {
  name           = "trusted-partners"
  address_family = "IPv4"
  max_entries    = 30

  entry {
    cidr        = "172.16.50.0/24"
    description = "Partner A - VPN egress"
  }

  entry {
    cidr        = "172.16.60.0/24"
    description = "Partner B - API servers"
  }

  tags = {
    Name        = "trusted-partners"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Outputs
output "corporate_offices_id" {
  value       = aws_ec2_managed_prefix_list.corporate_offices.id
  description = "Corporate offices prefix list ID"
}

output "datacentres_id" {
  value       = aws_ec2_managed_prefix_list.datacentres.id
  description = "Data centres prefix list ID"
}

output "partners_id" {
  value       = aws_ec2_managed_prefix_list.partners.id
  description = "Partners prefix list ID"
}
