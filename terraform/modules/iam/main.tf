# IAM roles and policies for blog portfolio application

# Developer IAM role with PowerUser permissions
resource "aws_iam_role" "developer_role" {
  name = "${var.project_name}-developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.developer_user_arn
        }
      }
    ]
  })

  tags = var.tags
}

# Attach PowerUser policy to developer role
resource "aws_iam_role_policy_attachment" "developer_poweruser" {
  role       = aws_iam_role.developer_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# GitHub Actions deployment role
resource "aws_iam_role" "github_actions_role" {
  name = "${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository}:*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# OpenID Connect provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = var.tags
}

# GitHub Actions deployment policy
resource "aws_iam_policy" "github_actions_policy" {
  name        = "${var.project_name}-github-actions-policy"
  description = "Policy for GitHub Actions to deploy blog portfolio application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECS permissions
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTasks"
        ]
        Resource = [
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.project_name}-*",
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:service/${var.project_name}-*/*",
          "arn:aws:ecs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:task-definition/${var.project_name}-*:*"
        ]
      },
      # ECR permissions
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = [
          "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.project_name}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      # S3 permissions for frontend deployment
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-frontend-*",
          "arn:aws:s3:::${var.project_name}-frontend-*/*"
        ]
      },
      # CloudFront permissions
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations"
        ]
        Resource = "*"
      },
      # IAM permissions for passing roles
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-*"
        ]
      }
    ]
  })

  tags = var.tags
}

# Attach GitHub Actions policy to role
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role for application
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# ECS Task Role Policy for application permissions
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${var.project_name}-ecs-task-policy"
  description = "Policy for ECS tasks to access required AWS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Secrets Manager permissions
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.project_name}/*"
        ]
      },
      # S3 permissions for static assets (if needed)
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-assets-*/*"
        ]
      },
      # CloudWatch Logs permissions
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.project_name}-*"
        ]
      }
    ]
  })

  tags = var.tags
}

# Attach ECS Task Policy to Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# OpenID Connect provider for Terraform Cloud
resource "aws_iam_openid_connect_provider" "terraform_cloud" {
  url = "https://app.terraform.io"

  client_id_list = [
    "aws.workload.identity"
  ]

  thumbprint_list = [
    "9e99a48a9960b14926bb7f3b02e22da2b0ab7280",
    "08745487e891c19e3078c1f2a07e452950ef36f6"
  ]

  tags = var.tags
}

# Terraform Cloud role for infrastructure management
resource "aws_iam_role" "terraform_cloud_role" {
  name = "${var.project_name}-terraform-cloud-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.terraform_cloud.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "app.terraform.io:aud" = "aws.workload.identity"
          }
          StringLike = {
            "app.terraform.io:sub" = "organization:${var.terraform_cloud_organization}:project:*:workspace:${var.terraform_cloud_workspace}:run_phase:*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Terraform Cloud policy for infrastructure management
resource "aws_iam_policy" "terraform_cloud_policy" {
  name        = "${var.project_name}-terraform-cloud-policy"
  description = "Policy for Terraform Cloud to manage AWS infrastructure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Full access for infrastructure management
      # Note: In production, you might want to restrict this further
      {
        Effect = "Allow"
        Action = "*"
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# Attach Terraform Cloud policy to role
resource "aws_iam_role_policy_attachment" "terraform_cloud_policy_attachment" {
  role       = aws_iam_role.terraform_cloud_role.name
  policy_arn = aws_iam_policy.terraform_cloud_policy.arn
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}