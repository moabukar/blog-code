# Cross-state references using terraform_remote_state
# Use this to reference outputs from other state files

# Reference networking state
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Reference security state
data "terraform_remote_state" "security" {
  backend = "s3"
  config = {
    bucket = "my-terraform-state"
    key    = "security/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Use outputs from networking state
resource "aws_eks_cluster" "main" {
  name     = "main-cluster"
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids         = data.terraform_remote_state.networking.outputs.private_subnet_ids
    security_group_ids = [data.terraform_remote_state.security.outputs.eks_security_group_id]
  }
}

# Use outputs from security state
resource "aws_instance" "app" {
  ami           = "ami-0abc123"
  instance_type = "t3.micro"
  subnet_id     = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]

  vpc_security_group_ids = [
    data.terraform_remote_state.security.outputs.app_security_group_id
  ]
}

# The networking state must export these outputs:
# output "vpc_id" { value = aws_vpc.main.id }
# output "private_subnet_ids" { value = aws_subnet.private[*].id }

# Dependency order when applying:
# 1. networking (no deps)
# 2. security (depends on networking)
# 3. eks (depends on networking, security)
# 4. application (depends on all)
