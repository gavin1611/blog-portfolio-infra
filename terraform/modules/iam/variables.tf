# Variables for IAM module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "developer_user_arn" {
  description = "ARN of the developer user who can assume the developer role"
  type        = string
  default     = ""
}

variable "github_repository" {
  description = "GitHub repository in the format owner/repo-name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}