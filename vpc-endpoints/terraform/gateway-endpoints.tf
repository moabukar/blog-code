# Gateway Endpoints - FREE
# Always use these for S3 and DynamoDB

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.route_table_ids

  # Optional: Add endpoint policy for restricted access
  policy = var.enable_endpoint_policies && length(var.allowed_s3_buckets) > 0 ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSpecificBuckets"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = flatten([
          for bucket in var.allowed_s3_buckets : [
            "arn:aws:s3:::${bucket}",
            "arn:aws:s3:::${bucket}/*"
          ]
        ])
      },
      {
        Sid       = "AllowECRBuckets"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["arn:aws:s3:::prod-${var.aws_region}-starport-layer-bucket/*"]
      }
    ]
  }) : null

  tags = {
    Name = "s3-gateway-endpoint"
    Type = "Gateway"
    Cost = "Free"
  }
}

# DynamoDB Gateway Endpoint
resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.route_table_ids

  tags = {
    Name = "dynamodb-gateway-endpoint"
    Type = "Gateway"
    Cost = "Free"
  }
}
