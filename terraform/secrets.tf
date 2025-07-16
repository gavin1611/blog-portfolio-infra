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
    DB_PASSWORD = aws_secretsmanager_secret_version.db_password.secret_string
  })
}

# Generate random database password
resource "random_password" "db_password" {
  length  = 32
  special = true
}