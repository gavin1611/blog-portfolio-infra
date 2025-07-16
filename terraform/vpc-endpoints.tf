# VPC Endpoints Configuration

################################################################################
# CloudFront VPC Origin for Private ALB Access
################################################################################

# CloudFront VPC Origin - connects CloudFront to private ALB
resource "aws_cloudfront_vpc_origin" "alb_origin" {
  vpc_origin_endpoint_config {
    name                   = "${local.name_prefix}-alb-origin"
    arn                    = aws_lb.main.arn
    http_port              = 8080
    https_port             = 8443
    origin_protocol_policy = "http-only"
    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }

  timeouts {
    create = "30m"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-vpc-origin"
    Type = "cloudfront-vpc-origin"
  })
}