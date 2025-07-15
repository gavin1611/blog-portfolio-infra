# Variables for Blog Portfolio Infrastructure
# This file defines all configurable parameters with validation rules
# and security considerations for ephemeral infrastructure deployment

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-east-1, eu-central-1, etc."
  }
}

variable "project_name" {
  description = "Name of the project used for resource naming and tagging"
  type        = string
  default     = "blog-portfolio"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name))
    error_message = "Project name must start with a letter, contain only lowercase letters, numbers, and hyphens, and end with a letter or number."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the infrastructure resources"
  type        = string
  default     = "blog-portfolio-team"

  validation {
    condition     = length(var.owner) > 0
    error_message = "Owner must be specified for resource tracking."
  }
}

variable "cost_center" {
  description = "Cost center for billing and cost allocation"
  type        = string
  default     = "engineering"
}

# Domain configuration (optional for custom domain setup)
variable "domain_name" {
  description = "Custom domain name for the application (optional)"
  type        = string
  default     = ""

  validation {
    condition     = var.domain_name == "" || can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]\\.[a-z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain format (e.g., example.com)."
  }
}

# ECS configuration for cost optimization
variable "ecs_cpu" {
  description = "CPU units for ECS Fargate task (256 = 0.25 vCPU)"
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.ecs_cpu)
    error_message = "ECS CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "ecs_memory" {
  description = "Memory for ECS Fargate task in MB (512 = 0.5 GB)"
  type        = number
  default     = 512

  validation {
    condition     = var.ecs_memory >= 512 && var.ecs_memory <= 30720
    error_message = "ECS memory must be between 512 MB and 30720 MB."
  }
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks (keep low for cost optimization)"
  type        = number
  default     = 1

  validation {
    condition     = var.ecs_desired_count >= 1 && var.ecs_desired_count <= 3
    error_message = "ECS desired count should be between 1 and 3 for cost optimization."
  }
}

# RDS configuration for free tier compliance
variable "db_instance_class" {
  description = "RDS instance class (t3.micro for free tier)"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition = contains([
      "db.t3.micro", "db.t3.small", "db.t3.medium",
      "db.t4g.micro", "db.t4g.small", "db.t4g.medium"
    ], var.db_instance_class)
    error_message = "DB instance class must be a valid t3 or t4g instance type."
  }
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB (20 GB free tier limit)"
  type        = number
  default     = 20

  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 100
    error_message = "DB allocated storage must be between 20 GB and 100 GB."
  }
}

variable "db_backup_retention_period" {
  description = "Backup retention period in days (0-35)"
  type        = number
  default     = 7

  validation {
    condition     = var.db_backup_retention_period >= 0 && var.db_backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

# Security configuration
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production

  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid CIDR notation."
  }
}

# Monitoring and alerting configuration
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (additional costs apply)"
  type        = bool
  default     = false
}

variable "cost_budget_limit" {
  description = "Monthly cost budget limit in USD"
  type        = number
  default     = 10

  validation {
    condition     = var.cost_budget_limit > 0 && var.cost_budget_limit <= 100
    error_message = "Cost budget limit must be between $1 and $100."
  }
}

variable "budget_alert_threshold" {
  description = "Budget alert threshold percentage (80 = 80%)"
  type        = number
  default     = 80

  validation {
    condition     = var.budget_alert_threshold > 0 && var.budget_alert_threshold <= 100
    error_message = "Budget alert threshold must be between 1% and 100%."
  }
}

# Feature flags for optional components
variable "enable_waf" {
  description = "Enable AWS WAF for additional security (additional costs apply)"
  type        = bool
  default     = false
}

variable "enable_backup" {
  description = "Enable automated backups for RDS"
  type        = bool
  default     = true
}

variable "enable_multi_az" {
  description = "Enable Multi-AZ deployment for RDS (additional costs apply)"
  type        = bool
  default     = false
}

# Ephemeral infrastructure configuration
variable "auto_destroy_schedule" {
  description = "Cron expression for automatic resource destruction (optional)"
  type        = string
  default     = ""

  validation {
    condition     = var.auto_destroy_schedule == "" || can(regex("^[0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+ [0-9*,-/]+$", var.auto_destroy_schedule))
    error_message = "Auto destroy schedule must be a valid cron expression or empty string."
  }
}

variable "resource_cleanup_tags" {
  description = "Additional tags for resource cleanup automation"
  type        = map(string)
  default = {
    AutoDestroy = "enabled"
    TTL         = "7d"
  }
}

variable "github_repository" {
  description = "GitHub repository for OIDC authentication (format: owner/repo-name)"
  type        = string
  default     = "gavin1611/blog-portfolio-infra"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$", var.github_repository))
    error_message = "GitHub repository must be in the format: owner/repo-name."
  }
}

# ECR Image Configuration
variable "use_placeholder_image" {
  description = "Use placeholder image for initial deployment (set to false after first app deployment)"
  type        = bool
  default     = true
}

variable "placeholder_image" {
  description = "Placeholder image to use when ECR repository is empty"
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:alpine"
}