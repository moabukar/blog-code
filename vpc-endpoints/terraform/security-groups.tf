# Security Group for VPC Endpoints
# Interface endpoints need a security group allowing HTTPS

resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints"
  description = "Security group for VPC interface endpoints"
  vpc_id      = var.vpc_id

  # Allow HTTPS from entire VPC
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  # No egress needed - endpoints don't initiate connections
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
