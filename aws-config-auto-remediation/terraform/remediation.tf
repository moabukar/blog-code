# S3 Encryption Remediation
resource "aws_config_remediation_configuration" "s3_encryption" {
  count = var.enable_auto_remediation ? 1 : 0

  config_rule_name = aws_config_config_rule.s3_encryption.name
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-EnableS3BucketEncryption"
  target_version   = "1"

  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "SSEAlgorithm"
    static_value = "AES256"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.config_remediation.arn
  }

  automatic                  = true
  maximum_automatic_attempts = var.remediation_retry_attempts
  retry_attempt_seconds      = var.remediation_retry_seconds

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = var.concurrent_execution_percentage
      error_percentage                     = var.error_percentage
    }
  }
}

# S3 Public Access Block Remediation
resource "aws_config_remediation_configuration" "s3_public_access" {
  count = var.enable_auto_remediation ? 1 : 0

  config_rule_name = aws_config_config_rule.s3_public_read.name
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWS-DisableS3BucketPublicReadWrite"
  target_version   = "1"

  parameter {
    name           = "S3BucketName"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.config_remediation.arn
  }

  automatic                  = true
  maximum_automatic_attempts = var.remediation_retry_attempts
  retry_attempt_seconds      = var.remediation_retry_seconds

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = var.concurrent_execution_percentage
      error_percentage                     = var.error_percentage
    }
  }
}

# S3 Versioning Remediation (using custom document)
resource "aws_config_remediation_configuration" "s3_versioning" {
  count = var.enable_auto_remediation ? 1 : 0

  config_rule_name = aws_config_config_rule.s3_versioning.name
  target_type      = "SSM_DOCUMENT"
  target_id        = aws_ssm_document.enable_s3_versioning.name

  parameter {
    name           = "BucketName"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.config_remediation.arn
  }

  automatic                  = true
  maximum_automatic_attempts = var.remediation_retry_attempts
  retry_attempt_seconds      = var.remediation_retry_seconds

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = var.concurrent_execution_percentage
      error_percentage                     = var.error_percentage
    }
  }
}

# EC2 IMDSv2 Remediation
resource "aws_config_remediation_configuration" "ec2_imdsv2" {
  count = var.enable_auto_remediation ? 1 : 0

  config_rule_name = aws_config_config_rule.ec2_imdsv2.name
  target_type      = "SSM_DOCUMENT"
  target_id        = aws_ssm_document.enable_imdsv2.name

  parameter {
    name           = "InstanceId"
    resource_value = "RESOURCE_ID"
  }

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.config_remediation.arn
  }

  automatic                  = true
  maximum_automatic_attempts = var.remediation_retry_attempts
  retry_attempt_seconds      = var.remediation_retry_seconds

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = var.concurrent_execution_percentage
      error_percentage                     = var.error_percentage
    }
  }
}
