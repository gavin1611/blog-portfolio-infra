# VPC Endpoints Configuration

################################################################################
# VPC Endpoints for CloudFront Private Origin Access
################################################################################

# Security Group for CloudFront VPC Endpoints
resource "aws_security_group" "cloudfront_vpc_endpoint" {
  name_prefix = "${local.name_prefix}-cf-vpce-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for CloudFront VPC endpoints"

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cf-vpce-sg"
    Type = "security-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Note: CloudFront VPC Origin Access is a newer feature that may not be fully supported
# in Terraform yet. For now, we'll configure the infrastructure to support private ALB
# access through CloudFront using the standard approach.

# VPC Endpoint for ALB (if needed for CloudFront VPC Origin Access)
# This is commented out as the feature may not be fully available yet
# resource "aws_vpc_endpoint" "alb" {
#   vpc_id              = module.vpc.vpc_id
#   service_name        = "com.amazonaws.vpce.${var.aws_region}.elasticloadbalancing"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = module.vpc.private_subnets
#   security_group_ids  = [aws_security_group.cloudfront_vpc_endpoint.id]
#   private_dns_enabled = true
#
#   tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-alb-vpce"
#     Type = "vpc-endpoint"
#   })
# }