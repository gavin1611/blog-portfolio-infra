# Security Groups Configuration

################################################################################
# Security Groups
################################################################################

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Application Load Balancer"

  ingress {
    description = "HTTP from CloudFront"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # CloudFront IP ranges - these are the current ranges but should be updated periodically
    cidr_blocks = [
      "13.32.0.0/15",
      "13.35.0.0/16",
      "18.238.0.0/15",
      "52.84.0.0/15",
      "54.182.0.0/16",
      "54.192.0.0/16",
      "54.230.0.0/16",
      "54.239.128.0/18",
      "54.239.192.0/19",
      "54.240.128.0/18",
      "99.84.0.0/16",
      "130.176.0.0/16",
      "204.246.164.0/22",
      "204.246.168.0/22",
      "204.246.174.0/23",
      "204.246.176.0/20",
      "205.251.192.0/19",
      "205.251.249.0/24",
      "205.251.250.0/23",
      "205.251.252.0/23",
      "205.251.254.0/24"
    ]
  }

  ingress {
    description = "HTTP Alt Port from CloudFront"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    # CloudFront IP ranges
    cidr_blocks = [
      "13.32.0.0/15",
      "13.35.0.0/16",
      "18.238.0.0/15",
      "52.84.0.0/15",
      "54.182.0.0/16",
      "54.192.0.0/16",
      "54.230.0.0/16",
      "54.239.128.0/18",
      "54.239.192.0/19",
      "54.240.128.0/18",
      "99.84.0.0/16",
      "130.176.0.0/16",
      "204.246.164.0/22",
      "204.246.168.0/22",
      "204.246.174.0/23",
      "204.246.176.0/20",
      "205.251.192.0/19",
      "205.251.249.0/24",
      "205.251.250.0/23",
      "205.251.252.0/23",
      "205.251.254.0/24"
    ]
  }

  ingress {
    description = "HTTPS from CloudFront"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # CloudFront IP ranges
    cidr_blocks = [
      "13.32.0.0/15",
      "13.35.0.0/16",
      "18.238.0.0/15",
      "52.84.0.0/15",
      "54.182.0.0/16",
      "54.192.0.0/16",
      "54.230.0.0/16",
      "54.239.128.0/18",
      "54.239.192.0/19",
      "54.240.128.0/18",
      "99.84.0.0/16",
      "130.176.0.0/16",
      "204.246.164.0/22",
      "204.246.168.0/22",
      "204.246.174.0/23",
      "204.246.176.0/20",
      "205.251.192.0/19",
      "205.251.249.0/24",
      "205.251.250.0/23",
      "205.251.252.0/23",
      "205.251.254.0/24"
    ]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
    Type = "security-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Security Group
resource "aws_security_group" "ecs" {
  name_prefix = "${local.name_prefix}-ecs-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for ECS Fargate tasks"

  ingress {
    description     = "HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-sg"
    Type = "security-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name_prefix = "${local.name_prefix}-rds-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for RDS PostgreSQL database"

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-sg"
    Type = "security-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}