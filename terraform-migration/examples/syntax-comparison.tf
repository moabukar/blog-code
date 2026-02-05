# syntax-comparison.tf
# Side-by-side comparison of 0.11 vs 0.12+ syntax

# ==================================================
# VARIABLE REFERENCES
# ==================================================

# 0.11 - String interpolation everywhere
# ami = "${var.ami_id}"

# 0.12+ - No interpolation needed for simple references
variable "ami_id" {
  type = string
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Still need interpolation for concatenation
  tags = {
    Name = "${var.environment}-web-${count.index}"
  }
}

# ==================================================
# TYPE CONSTRAINTS
# ==================================================

# 0.11 - Quotes around type
# type = "string"

# 0.12+ - No quotes
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

# ==================================================
# CONDITIONALS
# ==================================================

# 0.11 - count with ternary
# count = "${var.create_eip ? 1 : 0}"

# 0.12+ - Proper boolean
variable "create_eip" {
  type    = bool
  default = true
}

resource "aws_eip" "example" {
  count    = var.create_eip ? 1 : 0
  instance = aws_instance.example[0].id
}

# ==================================================
# LIST ACCESS
# ==================================================

# 0.11 - element function
# value = "${element(var.subnet_ids, 0)}"

# 0.12+ - Native indexing
output "first_subnet" {
  value = var.subnet_ids[0]
}

# ==================================================
# DYNAMIC BLOCKS (new in 0.12)
# ==================================================

variable "ingress_rules" {
  type = list(object({
    port        = number
    description = string
  }))
  default = []
}

resource "aws_security_group" "example" {
  name = "example"

  # 0.12+ - Dynamic blocks instead of multiple resources
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value.description
    }
  }
}

# ==================================================
# FOR EXPRESSIONS (new in 0.12)
# ==================================================

output "instance_ids" {
  value = [for i in aws_instance.example : i.id]
}

output "instance_map" {
  value = { for i in aws_instance.example : i.tags.Name => i.id }
}
