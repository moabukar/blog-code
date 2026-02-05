# ram-sharing.tf
# Share prefix lists across AWS accounts using RAM

variable "org_id" {
  description = "AWS Organizations ID"
  type        = string
}

variable "org_master_account_id" {
  description = "AWS Organizations master account ID"
  type        = string
}

# Create the prefix list (in networking account)
resource "aws_ec2_managed_prefix_list" "corporate" {
  name           = "corporate-networks"
  address_family = "IPv4"
  max_entries    = 100

  entry {
    cidr        = "10.0.0.0/8"
    description = "All corporate networks"
  }

  tags = {
    Name      = "corporate-networks"
    SharedVia = "RAM"
  }
}

# Create RAM resource share
resource "aws_ram_resource_share" "prefix_lists" {
  name                      = "shared-prefix-lists"
  allow_external_principals = false

  tags = {
    Name = "shared-prefix-lists"
  }
}

# Associate prefix list with RAM share
resource "aws_ram_resource_association" "corporate" {
  resource_arn       = aws_ec2_managed_prefix_list.corporate.arn
  resource_share_arn = aws_ram_resource_share.prefix_lists.arn
}

# Share with entire organization
resource "aws_ram_principal_association" "org" {
  principal          = "arn:aws:organizations::${var.org_master_account_id}:organization/${var.org_id}"
  resource_share_arn = aws_ram_resource_share.prefix_lists.arn
}

# Output for use in other accounts
output "shared_prefix_list_id" {
  value       = aws_ec2_managed_prefix_list.corporate.id
  description = "Use this ID in other accounts after RAM share is accepted"
}

output "shared_prefix_list_arn" {
  value = aws_ec2_managed_prefix_list.corporate.arn
}
