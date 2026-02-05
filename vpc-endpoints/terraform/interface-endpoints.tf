# Interface Endpoints - PrivateLink
# Cost: ~$0.01/hour per AZ + $0.01/GB data processed

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.interface_endpoints)

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"

  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  # Enable private DNS - critical for seamless SDK usage
  private_dns_enabled = true

  tags = {
    Name = "${replace(each.value, ".", "-")}-endpoint"
    Type = "Interface"
    Cost = "Paid"
  }
}
