# Monitoring and Cost Management Configuration

################################################################################
# Cost Monitoring and Budget Alerts
################################################################################

# SNS Topic for Budget Alerts
resource "aws_sns_topic" "budget_alerts" {
  name = "${local.name_prefix}-budget-alerts"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-budget-alerts"
    Type = "sns-topic"
  })
}

# Budget for Cost Monitoring
resource "aws_budgets_budget" "monthly_cost" {
  name         = "${local.name_prefix}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.cost_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  
  time_period_start = formatdate("YYYY-MM-01_00:00", timestamp())
  
  cost_filters = {
    Tag = [
      "Project:${var.project_name}",
      "Environment:${var.environment}"
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = var.budget_alert_threshold
    threshold_type            = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = []  # Add email addresses for alerts
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = var.budget_alert_threshold
    threshold_type            = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = []  # Add email addresses for alerts
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_alerts.arn]
  }

  tags = local.common_tags
}

################################################################################
# CloudWatch Dashboards for Monitoring
################################################################################

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.backend.name, "ClusterName", module.ecs.cluster_name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS Service Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", module.rds.db_instance_identifier],
            [".", "DatabaseConnections", ".", "."],
            [".", "FreeableMemory", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "RDS Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", aws_cloudfront_distribution.frontend.id],
            [".", "BytesDownloaded", ".", "."],
            [".", "4xxErrorRate", ".", "."],
            [".", "5xxErrorRate", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "CloudFront Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."],
            [".", "HTTPCode_Target_4XX_Count", ".", "."],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB Metrics"
          period  = 300
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-dashboard"
    Type = "cloudwatch-dashboard"
  })
}