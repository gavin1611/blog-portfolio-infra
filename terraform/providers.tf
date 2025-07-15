# Terraform and Provider Configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }

  # Terraform Cloud backend configuration
  cloud {
    organization = "blog-portfolio"
    workspaces {
      name = "blog-portfolio-infra"
    }
  }
}

# Configure the AWS Provider with default tags for resource management
provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources for cost tracking and management
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
      CostCenter  = var.cost_center
      # Ephemeral infrastructure tags for easy cleanup
      Ephemeral   = "true"
      CreatedBy   = "terraform"
      Repository  = "blog-portfolio-infra"
    }
  }
}