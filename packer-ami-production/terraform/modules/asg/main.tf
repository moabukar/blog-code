# terraform/modules/asg/main.tf
# Auto Scaling Group module with Launch Template and rolling updates

# Fetch AMI ID from SSM Parameter Store
# This allows Packer to update the parameter, and Terraform to read it
data "aws_ssm_parameter" "ami_id" {
  name = "/myapp/ami/${var.ami_version}"
}

# Alternative: Fetch AMI by tags (useful for cross-account scenarios)
data "aws_ami" "app" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["myapp-*"]
  }

  filter {
    name   = "tag:Application"
    values = [var.app_name]
  }

  # Optional: filter by specific version
  dynamic "filter" {
    for_each = var.ami_version != "latest" ? [1] : []
    content {
      name   = "tag:Version"
      values = [var.ami_version]
    }
  }
}

# Launch template - preferred over launch configurations
resource "aws_launch_template" "app" {
  name_prefix   = "${var.app_name}-${var.environment}-"
  image_id      = data.aws_ssm_parameter.ami_id.value
  instance_type = var.instance_type

  # Use IMDSv2 only (security best practice)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Enforces IMDSv2
    http_put_response_hop_limit = 1
  }

  # IAM role for the instance
  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  # Security groups
  vpc_security_group_ids = [aws_security_group.app.id]

  # User data for instance-specific configuration
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    environment = var.environment
    app_name    = var.app_name
  }))

  # Enable detailed monitoring
  monitoring {
    enabled = true
  }

  # Root volume (already encrypted in AMI, but explicit is good)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 30
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.app_name}-${var.environment}"
      Environment = var.environment
      Application = var.app_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.app_name}-${var.environment}"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "ELB"  # Use ALB health checks
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Rolling update configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 75  # Keep 75% healthy during update
      instance_warmup        = 120 # Wait 2 mins before considering healthy
    }
    triggers = ["tag"]  # Refresh when tags change
  }

  # Termination policy for predictable scaling
  termination_policies = ["OldestInstance"]

  # Tags propagated to instances
  tag {
    key                 = "Name"
    value               = "${var.app_name}-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  # AMI version tag for debugging
  tag {
    key                 = "AMI-Version"
    value               = var.ami_version
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    # Ignore desired_capacity changes from autoscaling
    ignore_changes = [desired_capacity]
  }
}

# Security group
resource "aws_security_group" "app" {
  name_prefix = "${var.app_name}-${var.environment}-"
  vpc_id      = var.vpc_id

  # Allow inbound from ALB only
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = var.alb_security_group_ids
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# IAM role for instances
resource "aws_iam_role" "app" {
  name_prefix = "${var.app_name}-${var.environment}-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# SSM access for Session Manager (no SSH needed)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name_prefix = "${var.app_name}-${var.environment}-"
  role        = aws_iam_role.app.name
}
