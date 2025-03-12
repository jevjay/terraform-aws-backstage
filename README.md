# AWS Backstage Terraform Module

This Terraform module deploys Backstage on AWS ECS with supporting infrastructure including:

- ECS Fargate service for running Backstage
- Application Load Balancer for traffic distribution
- S3 bucket for storing tech docs
- Optional PostgreSQL RDS database
- Optional ECR repository for container images
- IAM roles and security groups

## Features

- Deploy Backstage using either an external container image or from your own ECR repository
- Automatic provisioning of S3 bucket for tech docs
- Option to use an existing VPC or create a new one
- Database provisioning with secure password management
- Scalable ECS service with load balancing

## Usage

```hcl
module "backstage" {
  source = "github.com/jevjay/terraform-aws-backstage"

  name_prefix = "my-backstage"
  
  # VPC Settings - use existing VPC
  vpc_id                    = "vpc-1234567890abcdef0"
  existing_private_subnet_ids = ["subnet-1234567890abcdef0", "subnet-0fedcba0987654321"]
  existing_public_subnet_ids  = ["subnet-abcdef1234567890", "subnet-fedcba0987654321"]
  
  # Container settings
  container_image = "spotify/backstage:latest"
  container_port  = 7007
  desired_count   = 2
  
  # Database settings
  create_database = true
  
  # Environment variables for Backstage
  environment_variables = {
    NODE_ENV = "production"
    # Add your Backstage configuration here
  }
  
  tags = {
    Environment = "production"
    Project     = "developer-portal"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for resource names | `string` | `"backstage"` | no |
| vpc_id | ID of an existing VPC where resources will be created | `string` | `null` | no |
| vpc_cidr | CIDR block for the VPC (if creating a new one) | `string` | `"10.0.0.0/16"` | no |
| availability_zones | List of availability zones to use | `list(string)` | `["us-east-1a", "us-east-1b", "us-east-1c"]` | no |
| container_image | Backstage container image | `string` | `"spotify/backstage:latest"` | no |
| container_port | Port exposed by the container | `number` | `7007` | no |
| desired_count | Number of instances to run | `number` | `2` | no |
| create_database | Whether to create an RDS database for Backstage | `bool` | `true` | no |
| techdocs_bucket_name | Name for the S3 bucket to store tech docs | `string` | `null` | no |
| techdocs_bucket_versioning | Enable versioning for the tech docs
