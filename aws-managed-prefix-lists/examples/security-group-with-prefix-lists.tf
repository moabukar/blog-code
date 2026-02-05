# security-group-with-prefix-lists.tf
# Complete security group example using prefix lists

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "prefix_list_offices" {
  description = "Corporate offices prefix list ID"
  type        = string
}

variable "prefix_list_datacentres" {
  description = "Data centres prefix list ID"
  type        = string
}

# Bastion host security group
resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Bastion host security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion-sg"
  }
}

# SSH from corporate offices
resource "aws_security_group_rule" "bastion_ssh_offices" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  prefix_list_ids   = [var.prefix_list_offices]
  security_group_id = aws_security_group.bastion.id
  description       = "SSH from corporate offices"
}

# SSH from data centres
resource "aws_security_group_rule" "bastion_ssh_datacentres" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  prefix_list_ids   = [var.prefix_list_datacentres]
  security_group_id = aws_security_group.bastion.id
  description       = "SSH from data centres"
}

# Egress
resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
  description       = "Allow all outbound"
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
}
