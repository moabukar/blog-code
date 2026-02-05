# ==============================================
# AWS Provider 3.x - Single monolithic resource
# ==============================================

# resource "aws_s3_bucket" "data" {
#   bucket = "my-data-bucket"
#   acl    = "private"
#
#   versioning {
#     enabled = true
#   }
#
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "aws:kms"
#         kms_master_key_id = aws_kms_key.bucket_key.arn
#       }
#     }
#   }
#
#   lifecycle_rule {
#     id      = "archive"
#     enabled = true
#
#     transition {
#       days          = 90
#       storage_class = "GLACIER"
#     }
#
#     expiration {
#       days = 365
#     }
#   }
#
#   tags = {
#     Environment = "production"
#   }
# }


# ==============================================
# AWS Provider 4.x+ - Separate resources
# ==============================================

resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"

  tags = {
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.bucket_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    id     = "archive"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Note: ACLs require ownership controls to be compatible
# resource "aws_s3_bucket_acl" "data" {
#   bucket = aws_s3_bucket.data.id
#   acl    = "private"
#
#   depends_on = [aws_s3_bucket_ownership_controls.data]
# }
