# Main entry point for AWS Backstage deployment

locals {
  name_prefix = var.name_prefix != null ? var.name_prefix : "backstage"
  tags = merge(
    var.tags,
    {
      "Terraform"   = "true"
      "Application" = "backstage"
    }
  )
}

# Create VPC if not provided
module "vpc" {
  count = var.vpc_id == null ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  tags = local.tags
}

# Security groups
resource "aws_security_group" "backstage_alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Backstage ALB"
  vpc_id      = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id

  ingress {
    description = "HTTP ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  ingress {
    description = "HTTPS ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "backstage_ecs" {
  name        = "${local.name_prefix}-ecs-sg"
  description = "Security group for Backstage ECS tasks"
  vpc_id      = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backstage_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "backstage_db" {
  name        = "${local.name_prefix}-db-sg"
  description = "Security group for Backstage database"
  vpc_id      = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id

  ingress {
    description     = "Allow traffic from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backstage_ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}
