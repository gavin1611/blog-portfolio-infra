# VPC and Networking Configuration

################################################################################
# VPC Module from Terraform Registry
# Using the proven terraform-aws-modules/vpc/aws module for reliability
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-vpc"
  cidr = local.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 20)]

  # Internet connectivity
  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true # Cost optimization for prod

  # DNS settings
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Security and monitoring
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  flow_log_cloudwatch_log_group_retention_in_days = 7

  # Database subnet group
  create_database_subnet_group = true
  database_subnet_group_name   = "${local.name_prefix}-db-subnet-group"

  # Public subnet settings
  map_public_ip_on_launch = true

  tags = local.common_tags
}