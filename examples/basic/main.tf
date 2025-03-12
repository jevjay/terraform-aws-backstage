provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-example"
  acl    = "private"
}

module "backstage" {
  source = "../.."

  name_prefix = "example-backstage"
  
  # VPC Settings
  availability_zones   = ["us-east-1a", "us-east-1b"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # Container settings
  container_image = "spotify/backstage:latest"
  container_port  = 7007
  cpu             = 1024
  memory          = 2048
  desired_count   = 1
  
  # Database settings
  create_database = true
  database_credentials = {
    username = "backstage"
    password = null  # Will be auto-generated
  }
  
  environment_variables = {
    NODE_ENV = "production"
  }
  
  tags = {
    Environment = "example"
    Project     = "backstage"
  }
}
