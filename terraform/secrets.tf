# Secrets Manager Configuration

################################################################################
# Secrets Manager for Database Password
################################################################################

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${local.name_prefix}/database/password"
  description             = "Database password for ${local.name_prefix}"
  recovery_window_in_days = 7

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-password"
    Type = "secret"
  })
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = local.db_username
    password = "managed-by-rds" # Password is managed by RDS when using manage_master_user_password
    engine   = "postgres"
    host     = module.rds.db_instance_endpoint
    port     = 5432
    dbname   = local.db_name
    # The actual password is stored in the RDS-managed secret
    rds_secret_arn = module.rds.db_instance_master_user_secret_arn
  })
}