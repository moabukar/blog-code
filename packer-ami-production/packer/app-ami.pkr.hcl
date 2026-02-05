# app-ami.pkr.hcl
# Production Packer template for building application AMIs

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Variables - passed from CI or .auto.pkrvars.hcl
variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "app_version" {
  type        = string
  description = "Application version - typically git SHA or semver"
}

variable "base_ami_name" {
  type    = string
  default = "amzn2-ami-hvm-*-x86_64-gp2"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
  # Use same instance type as production for accurate builds
}

variable "vpc_id" {
  type        = string
  description = "VPC for build instance - use dedicated build VPC"
}

variable "subnet_id" {
  type        = string
  description = "Subnet for build instance - private subnet recommended"
}

# Find the latest Amazon Linux 2 AMI
source "amazon-ebs" "app" {
  ami_name        = "myapp-${var.app_version}-{{timestamp}}"
  ami_description = "MyApp AMI - Version ${var.app_version}"
  instance_type   = var.instance_type
  region          = var.aws_region

  # Source AMI filter - always builds from latest base
  source_ami_filter {
    filters = {
      name                = var.base_ami_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  # Network configuration
  vpc_id                      = var.vpc_id
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false  # Private subnet, use NAT

  # Security: Use SSM instead of SSH
  communicator         = "ssh"
  ssh_username         = "ec2-user"
  ssh_interface        = "session_manager"
  iam_instance_profile = "PackerBuildRole"

  # EBS configuration
  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 30
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    encrypted             = true  # Always encrypt root volumes
    delete_on_termination = true
  }

  # Tags - critical for Terraform lookups and cost tracking
  tags = {
    Name        = "myapp-${var.app_version}"
    Application = "myapp"
    Version     = var.app_version
    BuildTime   = "{{timestamp}}"
    Builder     = "packer"
    Environment = "all"  # AMI usable in any environment
  }

  # Snapshot tags for cost tracking
  snapshot_tags = {
    Name        = "myapp-${var.app_version}"
    Application = "myapp"
  }

  # Build timeout - fail fast if something's wrong
  aws_polling {
    delay_seconds = 30
    max_attempts  = 60
  }
}

build {
  name    = "myapp"
  sources = ["source.amazon-ebs.app"]

  # Base OS setup
  provisioner "shell" {
    scripts = [
      "scripts/base-setup.sh"
    ]
    environment_vars = [
      "APP_VERSION=${var.app_version}"
    ]
  }

  # Application installation
  provisioner "shell" {
    script = "scripts/app-install.sh"
    environment_vars = [
      "APP_VERSION=${var.app_version}"
    ]
  }

  # Optional: Ansible for complex configuration
  # provisioner "ansible" {
  #   playbook_file = "ansible/playbook.yml"
  #   extra_arguments = [
  #     "--extra-vars", "app_version=${var.app_version}"
  #   ]
  # }

  # CRITICAL: Always run cleanup last
  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  # Output AMI ID for downstream use
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
