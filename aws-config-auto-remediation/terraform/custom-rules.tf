# Custom Rule: EC2 Approved Instance Types (using Guard)
resource "aws_config_config_rule" "ec2_instance_types" {
  name = "ec2-approved-instance-types"

  source {
    owner = "CUSTOM_POLICY"

    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }

    custom_policy_details {
      policy_runtime = "guard-2.x.x"
      policy_text    = <<-POLICY
        rule ec2_approved_instance_types when resourceType == "AWS::EC2::Instance" {
          configuration.instanceType IN [
            "t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge",
            "t3a.micro", "t3a.small", "t3a.medium", "t3a.large", "t3a.xlarge",
            "m6i.large", "m6i.xlarge", "m6i.2xlarge",
            "c6i.large", "c6i.xlarge", "c6i.2xlarge",
            "r6i.large", "r6i.xlarge", "r6i.2xlarge"
          ]
        }
      POLICY
    }
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Custom Rule: S3 Bucket Logging Required
resource "aws_config_config_rule" "s3_logging_required" {
  name = "s3-bucket-logging-required"

  source {
    owner = "CUSTOM_POLICY"

    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }

    custom_policy_details {
      policy_runtime = "guard-2.x.x"
      policy_text    = <<-POLICY
        rule s3_logging_enabled when resourceType == "AWS::S3::Bucket" {
          supplementaryConfiguration.BucketLoggingConfiguration.destinationBucketName EXISTS
        }
      POLICY
    }
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Custom Rule: No Public Subnets in VPC
resource "aws_config_config_rule" "no_public_subnets" {
  name = "vpc-no-public-subnets-check"

  source {
    owner = "CUSTOM_POLICY"

    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }

    custom_policy_details {
      policy_runtime = "guard-2.x.x"
      policy_text    = <<-POLICY
        rule no_auto_public_ip when resourceType == "AWS::EC2::Subnet" {
          configuration.mapPublicIpOnLaunch == false
        }
      POLICY
    }
  }

  depends_on = [aws_config_configuration_recorder.main]
}
