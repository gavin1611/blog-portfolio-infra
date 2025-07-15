# KMS Keys for Encryption

################################################################################
# KMS Key for RDS Encryption
################################################################################

resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-kms-key"
    Type = "kms-key"
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${local.name_prefix}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

################################################################################
# KMS Key for ECS Logs
################################################################################

resource "aws_kms_key" "ecs_logs" {
  description             = "KMS key for ECS CloudWatch logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-logs-kms-key"
    Type = "kms-key"
  })
}

resource "aws_kms_alias" "ecs_logs" {
  name          = "alias/${local.name_prefix}-ecs-logs"
  target_key_id = aws_kms_key.ecs_logs.key_id
}