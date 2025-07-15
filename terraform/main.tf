# Main Terraform configuration for Blog Portfolio Infrastructure
# This configuration follows AWS Well-Architected Framework principles
# and implements security best practices with Checkov compliance
# Uses proven modules from Terraform Registry for reliability and maintainability

################################################################################
# IAM Module
################################################################################

module "iam" {
  source = "./modules/iam"

  project_name      = var.project_name
  aws_region        = var.aws_region
  github_repository = var.github_repository
  tags              = local.common_tags
}