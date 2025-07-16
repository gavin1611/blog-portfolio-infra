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

# VPC Endpoint for CloudFront
resource "aws_vpc_endpoint" "cloudfront" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.vpce.${var.aws_region}.vpce-svc-cloudfront"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.cloudfront_vpc_endpoint.id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-cloudfront-vpce"
    Type = "vpc-endpoint"
  })
}