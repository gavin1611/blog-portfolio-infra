# ECS Configuration

################################################################################
# ECS Module from Terraform Registry
################################################################################

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "${local.name_prefix}-cluster"

  # Fargate capacity providers
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  # CloudWatch Log Group
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 7
  cloudwatch_log_group_kms_key_id        = aws_kms_key.ecs_logs.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecs-cluster"
    Type = "ecs-cluster"
  })
}

################################################################################
# ECS Task Definition and Service
################################################################################

# ECS Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.name_prefix}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = module.iam.ecs_task_execution_role_arn
  task_role_arn            = module.iam.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${aws_ecr_repository.backend.repository_url}:latest"

      essential = true

      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "PORT"
          value = "8080"
        },
        {
          name  = "ENV"
          value = var.environment
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = aws_secretsmanager_secret.db_password.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${local.name_prefix}-backend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-task-definition"
    Type = "ecs-task-definition"
  })
}

# ECS Service
resource "aws_ecs_service" "backend" {
  name            = "${local.name_prefix}-backend"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8080
  }

  # Enable service discovery
  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }

  # Deployment configuration
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  # Enable execute command for debugging
  enable_execute_command = false

  depends_on = [aws_lb_listener.backend]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-service"
    Type = "ecs-service"
  })
}

################################################################################
# CloudWatch Log Group for ECS
################################################################################

resource "aws_cloudwatch_log_group" "ecs_backend" {
  name              = "/ecs/${local.name_prefix}-backend"
  retention_in_days = 7
  kms_key_id        = aws_kms_key.ecs_logs.arn

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-logs"
    Type = "cloudwatch-log-group"
  })
}