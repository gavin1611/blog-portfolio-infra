# Outputs for blog portfolio infrastructure
# These outputs provide important resource information for CI/CD and application configuration

################################################################################
# Network Outputs
################################################################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

################################################################################
# Database Outputs
################################################################################

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_instance_port
}

output "database_name" {
  description = "Name of the database"
  value       = module.rds.db_instance_name
}

output "database_username" {
  description = "Database master username"
  value       = module.rds.db_instance_username
  sensitive   = true
}

output "db_secret_arn" {
  description = "ARN of the database password secret"
  value       = aws_secretsmanager_secret.db_password.arn
}

################################################################################
# S3 Outputs
################################################################################

output "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_bucket_arn" {
  description = "ARN of the S3 bucket for frontend hosting"
  value       = aws_s3_bucket.frontend.arn
}

output "assets_bucket_name" {
  description = "Name of the S3 bucket for assets"
  value       = aws_s3_bucket.assets.bucket
}

output "assets_bucket_arn" {
  description = "ARN of the S3 bucket for assets"
  value       = aws_s3_bucket.assets.arn
}

################################################################################
# CloudFront Outputs
################################################################################

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "website_url" {
  description = "URL of the website"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

################################################################################
# Load Balancer Outputs
################################################################################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.backend.arn
}

################################################################################
# Security Group Outputs
################################################################################

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS security group"
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

################################################################################
# IAM Outputs
################################################################################

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = module.iam.github_actions_role_arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.iam.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.iam.ecs_task_role_arn
}

################################################################################
# Environment Information
################################################################################

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

################################################################################
# Cost Optimization Information
################################################################################

output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    rds_instance       = "~$13.87/month (db.t3.micro)"
    nat_gateway        = "~$32.40/month (single NAT gateway)"
    alb                = "~$16.20/month (Application Load Balancer)"
    cloudfront         = "~$1.00/month (1TB transfer)"
    s3_storage         = "~$0.50/month (20GB storage)"
    ecs_fargate        = "~$5.00/month (0.25 vCPU, 0.5GB RAM)"
    total_estimated    = "~$68.97/month"
    free_tier_eligible = "RDS, S3, CloudFront, ECS Fargate (first 12 months)"
  }
}

output "cost_optimization_notes" {
  description = "Cost optimization recommendations"
  value = [
    "RDS: Using db.t3.micro (free tier eligible for first 12 months)",
    "ECS: Using minimal resources (0.25 vCPU, 0.5GB RAM)",
    "NAT Gateway: Using single NAT gateway instead of per-AZ",
    "CloudFront: Using PriceClass_100 (North America and Europe only)",
    "S3: Using Intelligent Tiering for automatic cost optimization",
    "Monitoring: Basic monitoring enabled (detailed monitoring disabled for cost savings)"
  ]
} ###########
#####################################################################
# ECS Outputs
################################################################################

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.backend.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.backend.arn
}

################################################################################
# ECR Outputs
################################################################################

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.backend.arn
}

################################################################################
# Service Discovery Outputs
################################################################################

output "service_discovery_namespace_id" {
  description = "ID of the service discovery namespace"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "service_discovery_service_arn" {
  description = "ARN of the service discovery service"
  value       = aws_service_discovery_service.backend.arn
}