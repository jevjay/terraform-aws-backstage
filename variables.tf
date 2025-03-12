variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "backstage"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# VPC Settings
variable "vpc_id" {
  description = "ID of an existing VPC where resources will be created (if not provided, a new VPC will be created)"
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (only used if vpc_id is not provided)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use (only used if vpc_id is not provided)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (only used if vpc_id is not provided)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (only used if vpc_id is not provided)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "single_nat_gateway" {
  description = "Whether to use a single shared NAT Gateway across all private networks"
  type        = bool
  default     = true
}

variable "existing_private_subnet_ids" {
  description = "List of existing private subnet IDs (required if vpc_id is provided)"
  type        = list(string)
  default     = []
}

variable "existing_public_subnet_ids" {
  description = "List of existing public subnet IDs (required if vpc_id is provided)"
  type        = list(string)
  default     = []
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks that can access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Container Settings
variable "container_image" {
  description = "Backstage container image (ECR or external image)"
  type        = string
  default     = "spotify/backstage:latest"
}

variable "container_port" {
  description = "Port exposed by the Backstage container"
  type        = number
  default     = 7007
}

variable "use_existing_ecr" {
  description = "Whether to use an existing ECR repository"
  type        = bool
  default     = false
}

variable "existing_ecr_repository_name" {
  description = "Name of existing ECR repository (if use_existing_ecr is true)"
  type        = string
  default     = null
}

variable "cpu" {
  description = "CPU units for the Backstage container"
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Memory for the Backstage container (in MiB)"
  type        = number
  default     = 2048
}

variable "desired_count" {
  description = "Number of Backstage instances to run"
  type        = number
  default     = 2
}

variable "environment_variables" {
  description = "Environment variables for the Backstage container"
  type        = map(string)
  default     = {}
  sensitive   = true
}

# Database Settings
variable "create_database" {
  description = "Whether to create an RDS database for Backstage"
  type        = bool
  default     = true
}

variable "database_credentials" {
  description = "Database credentials for Backstage"
  type = object({
    username = string
    password = string
  })
  default = {
    username = "backstage"
    password = null  # Will be generated if not provided
  }
  sensitive = true
}

variable "database_allocated_storage" {
  description = "Allocated storage for the database (in GB)"
  type        = number
  default     = 20
}

variable "database_instance_class" {
  description = "Instance class for the database"
  type        = string
  default     = "db.t3.small"
}

# Tech Docs S3 Settings
variable "techdocs_bucket_name" {
  description = "Name for the S3 bucket to store tech docs (will be auto-generated if not provided)"
  type        = string
  default     = null
}

variable "techdocs_bucket_versioning" {
  description = "Enable versioning for the tech docs bucket"
  type        = bool
  default     = true
}
