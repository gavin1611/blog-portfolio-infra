# Production environment configuration for blog portfolio infrastructure
# This file contains production-specific values that override defaults

# Environment configuration
environment = "prod"
owner       = "blog-portfolio-team"
cost_center = "engineering"
project_name = "blog-portfolio"

# GitHub repository (update with your actual repository)
github_repository = "gavin1611/blog-portfolio-infra"

# Domain configuration (optional - update with your domain)
domain_name = ""  # Set to your custom domain if you have one

# ECS configuration for production
ecs_cpu           = 256   # 0.25 vCPU (free tier eligible)
ecs_memory        = 512   # 0.5 GB (free tier eligible)
ecs_desired_count = 1     # Single instance for cost optimization

# RDS configuration for production
db_instance_class           = "db.t3.micro"  # Free tier eligible
db_allocated_storage        = 20             # Free tier limit
db_backup_retention_period  = 7              # 7 days backup retention
enable_backup              = true
enable_multi_az            = false           # Disabled for cost optimization

# Security configuration
allowed_cidr_blocks = ["0.0.0.0/0"]  # Allow all - restrict as needed

# Monitoring and cost control
enable_detailed_monitoring = false    # Disabled for cost optimization
cost_budget_limit         = 10       # $10 monthly budget
budget_alert_threshold    = 80       # Alert at 80% of budget

# Feature flags
enable_waf = false  # Disabled for cost optimization

# Ephemeral infrastructure settings
auto_destroy_schedule = ""  # No auto-destroy for production

resource_cleanup_tags = {
  AutoDestroy = "disabled"
  TTL         = "permanent"
  Backup      = "enabled"
}