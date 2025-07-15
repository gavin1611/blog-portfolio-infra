# Blog Portfolio Infrastructure

This repository contains the Infrastructure as Code (IaC) for the blog portfolio application using Terraform and AWS services. The infrastructure follows AWS Well-Architected Framework principles with a focus on cost optimization and security.

## 🏗️ Architecture Overview

The infrastructure deploys a modern, scalable web application with the following components:

- **Frontend**: React SPA hosted on S3 with CloudFront CDN
- **Backend**: Go API running on ECS Fargate
- **Database**: PostgreSQL on RDS
- **Load Balancer**: Application Load Balancer
- **Container Registry**: Amazon ECR
- **Monitoring**: CloudWatch with custom dashboards
- **Security**: IAM roles with least privilege, KMS encryption

## 💰 Cost Optimization

The infrastructure is designed to stay within AWS Free Tier limits where possible:

- **RDS**: db.t3.micro instance (free tier eligible)
- **ECS Fargate**: 0.25 vCPU, 0.5GB RAM (free tier eligible)
- **S3**: Intelligent Tiering for automatic cost optimization
- **CloudFront**: PriceClass_100 (North America and Europe only)
- **NAT Gateway**: Single NAT gateway instead of per-AZ

**Estimated Monthly Cost**: ~$69/month (significantly reduced with free tier)

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **Terraform Cloud** account (optional but recommended)
4. **Checkov** for security scanning (optional)

### Environment Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd blog-portfolio-infra
   ```

2. **Configure Terraform Cloud** (recommended):
   ```bash
   # Update terraform/main.tf with your Terraform Cloud organization
   # Or use local backend by removing the cloud block
   ```

3. **Set up environment variables**:
   ```bash
   export TF_VAR_environment="dev"
   export TF_VAR_owner="your-name"
   export TF_VAR_github_repository="your-username/blog-portfolio-infra"
   ```

### Deployment

1. **Initialize Terraform**:
   ```bash
   cd terraform
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan -var-file="environments/dev.tfvars"
   ```

3. **Apply the infrastructure**:
   ```bash
   terraform apply -var-file="environments/dev.tfvars"
   ```

4. **Verify deployment**:
   ```bash
   terraform output
   ```

## 🔧 Configuration

### Environment Files

- `environments/dev.tfvars` - Development environment settings
- `environments/prod.tfvars` - Production environment settings

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment` | Environment name (dev/staging/prod) | - |
| `owner` | Resource owner for tagging | - |
| `ecs_cpu` | ECS task CPU units | 256 |
| `ecs_memory` | ECS task memory in MB | 512 |
| `db_instance_class` | RDS instance class | db.t3.micro |
| `cost_budget_limit` | Monthly budget limit in USD | 10 |

## 🛡️ Security

### Security Features

- **Encryption**: All data encrypted at rest and in transit
- **IAM**: Least privilege access with specific resource ARNs
- **VPC**: Private subnets for database and application
- **Security Groups**: Restrictive ingress/egress rules
- **Secrets Management**: AWS Secrets Manager for sensitive data

### Security Scanning

Run Checkov for security compliance:

```bash
checkov -d terraform/ --config-file .checkov.yml
```

## 📊 Monitoring

### CloudWatch Dashboards

The infrastructure includes pre-configured dashboards for:

- ECS service metrics (CPU, memory)
- RDS database metrics (connections, CPU)
- CloudFront distribution metrics (requests, errors)

### Cost Monitoring

- **Budget Alerts**: Configured to alert at 80% of monthly budget
- **Cost Allocation Tags**: All resources tagged for cost tracking
- **Resource Cleanup**: Optional automated cleanup for dev environments

## 🔄 CI/CD Integration

### GitHub Actions

The infrastructure supports GitHub Actions deployment with:

- **OIDC Authentication**: No long-lived credentials
- **Scoped Permissions**: Minimal required permissions
- **Multi-Environment**: Support for dev/staging/prod

### Required Secrets

Configure these in your GitHub repository:

- `AWS_REGION`: AWS region for deployment
- `TF_VAR_environment`: Environment name
- `TF_VAR_owner`: Resource owner

## 🧹 Ephemeral Infrastructure

### Auto-Cleanup (Development)

For development environments, enable automatic resource cleanup:

```hcl
auto_destroy_schedule = "0 2 * * 0"  # Every Sunday at 2 AM
```

### Manual Cleanup

To destroy all resources:

```bash
terraform destroy -var-file="environments/dev.tfvars"
```

## 📋 Outputs

Key outputs available after deployment:

- `website_url`: CloudFront distribution URL
- `ecr_repository_url`: ECR repository for container images
- `rds_endpoint`: Database endpoint (sensitive)
- `github_actions_role_arn`: IAM role for GitHub Actions

## 🔍 Troubleshooting

### Common Issues

1. **Terraform State Lock**: 
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **Resource Limits**: Check AWS service quotas in your region

3. **Cost Alerts**: Monitor CloudWatch for budget notifications

### Debugging

- Enable ECS execute command for container debugging (dev only)
- Check CloudWatch logs for application and infrastructure events
- Use AWS X-Ray for distributed tracing (if enabled)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Run security scans: `checkov -d terraform/`
4. Test in development environment
5. Submit a pull request

## 📚 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Checkov Security Scanning](https://www.checkov.io/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: Remember to update the GitHub repository URL and Terraform Cloud organization name in the configuration files before deployment.