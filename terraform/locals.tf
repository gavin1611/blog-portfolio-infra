# Data sources and local values

# Data source for current AWS account information
data "aws_caller_identity" "current" {}

# Data source for available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for consistent naming and configuration
locals {
  # Naming convention: project-environment-resource-suffix
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Ephemeral   = "true"
    CreatedBy   = "terraform"
    Repository  = "blog-portfolio-infra"
  }

  # AZ selection for multi-AZ deployment
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # CIDR blocks for VPC and subnets
  vpc_cidr = "10.0.0.0/16"

  # Database configuration
  db_name     = replace(var.project_name, "-", "_")
  db_username = "blog_admin"
}