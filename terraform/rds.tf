# RDS Database Configuration

################################################################################
# RDS Module from Terraform Registry
################################################################################

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${local.name_prefix}-db"

  # Database configuration
  engine               = "postgres"
  engine_version       = "15.7"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 2

  # Database credentials
  db_name  = local.db_name
  username = local.db_username
  password = random_password.db_password.result
  port     = 5432

  # Security
  manage_master_user_password = false
  vpc_security_group_ids      = [aws_security_group.rds.id]
  db_subnet_group_name        = module.vpc.database_subnet_group_name

  # Backup configuration
  backup_retention_period = var.db_backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Monitoring and performance
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true
  monitoring_interval             = var.enable_detailed_monitoring ? 60 : 0
  monitoring_role_name            = "${local.name_prefix}-rds-monitoring-role"
  create_monitoring_role          = var.enable_detailed_monitoring

  # Multi-AZ and encryption
  multi_az          = var.enable_multi_az
  storage_encrypted = true

  # Deletion protection and final snapshot
  deletion_protection = false
  skip_final_snapshot = false

  tags = local.common_tags
}