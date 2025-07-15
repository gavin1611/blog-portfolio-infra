# Terraform Cloud Manual OIDC Setup Guide

## Overview

This guide walks you through manually creating the Terraform Cloud OIDC provider and IAM role to solve the chicken-and-egg problem. You need to create these resources manually first, then Terraform Cloud can manage everything else.

## Prerequisites

- AWS CLI configured with administrative access
- Terraform Cloud account and organization
- Your AWS Account ID

## Step 1: Create OIDC Identity Provider

### Via AWS Console

1. Go to **IAM Console** → **Identity providers** → **Add provider**
2. Choose **OpenID Connect**
3. Set these values:
   - **Provider URL**: `https://app.terraform.io`
   - **Audience**: `aws.workload.identity`
4. Click **Get thumbprint** (it should auto-populate)
5. Click **Add provider**

### Via AWS CLI

```bash
aws iam create-open-id-connect-provider \
  --url https://app.terraform.io \
  --client-id-list aws.workload.identity \
  --thumbprint-list 9e99a48a9960b14926bb7f3b02e22da2b0ab7280
```

## Step 2: Create IAM Role

### Get Your Account ID

```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Your AWS Account ID: $AWS_ACCOUNT_ID"
```

### Create Trust Policy

Create a file called `terraform-cloud-trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/app.terraform.io"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "app.terraform.io:aud": "aws.workload.identity"
        },
        "StringLike": {
          "app.terraform.io:sub": "organization:YOUR_TFC_ORG:project:*:workspace:blog-portfolio-prod:run_phase:*"
        }
      }
    }
  ]
}
```

**Replace the following placeholders:**
- `YOUR_ACCOUNT_ID` with your AWS Account ID
- `YOUR_TFC_ORG` with your Terraform Cloud organization name

### Create the Role via AWS CLI

```bash
# Replace YOUR_TFC_ORG with your actual Terraform Cloud organization name
export TFC_ORG="your-terraform-cloud-org"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create the trust policy file
cat > terraform-cloud-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/app.terraform.io"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "app.terraform.io:aud": "aws.workload.identity"
        },
        "StringLike": {
          "app.terraform.io:sub": "organization:${TFC_ORG}:project:*:workspace:blog-portfolio-prod:run_phase:*"
        }
      }
    }
  ]
}
EOF

# Create the IAM role
aws iam create-role \
  --role-name blog-portfolio-terraform-cloud-role \
  --assume-role-policy-document file://terraform-cloud-trust-policy.json \
  --description "Terraform Cloud role for blog-portfolio infrastructure"

# Attach AdministratorAccess policy (you can restrict this later)
aws iam attach-role-policy \
  --role-name blog-portfolio-terraform-cloud-role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Get the role ARN for the next step
aws iam get-role \
  --role-name blog-portfolio-terraform-cloud-role \
  --query 'Role.Arn' \
  --output text
```

## Step 3: Configure Terraform Cloud Workspace

1. Go to your Terraform Cloud workspace: `blog-portfolio-prod`
2. Go to **Settings** → **Variables**
3. Add these **Environment Variables**:

| Variable Name | Value | Sensitive |
|---------------|-------|-----------|
| `TFC_AWS_PROVIDER_AUTH` | `true` | No |
| `TFC_AWS_RUN_ROLE_ARN` | `arn:aws:iam::YOUR_ACCOUNT_ID:role/blog-portfolio-terraform-cloud-role` | No |

**Replace `YOUR_ACCOUNT_ID` with your actual AWS Account ID**

## Step 4: Configure Terraform Variables

Add these **Terraform Variables** in your workspace:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `environment` | `prod` | Environment name |
| `owner` | `your-name` | Owner of resources |
| `github_repository` | `your-username/blog-portfolio-app` | GitHub repo for app deployment |

## Step 5: Update Terraform Cloud Configuration

Update your `terraform/providers.tf` file to use your actual organization name:

```hcl
terraform {
  # ... other configuration ...
  
  cloud {
    organization = "your-actual-terraform-cloud-org"  # Replace this
    workspaces {
      name = "blog-portfolio-prod"
    }
  }
}
```

## Step 6: Test the Configuration

1. Push your changes to GitHub
2. Go to your Terraform Cloud workspace
3. Click **Actions** → **Start new run**
4. Select **Plan only** to test
5. If successful, you can apply the changes

## Security Best Practices

### Restrict IAM Permissions (Recommended)

Instead of using `AdministratorAccess`, create a custom policy with only the required permissions:

```bash
# Create a custom policy (example - adjust as needed)
cat > terraform-cloud-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "ecs:*",
        "rds:*",
        "s3:*",
        "cloudfront:*",
        "iam:*",
        "logs:*",
        "secretsmanager:*",
        "kms:*",
        "elasticloadbalancing:*",
        "servicediscovery:*",
        "ecr:*",
        "budgets:*",
        "sns:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# Create the policy
aws iam create-policy \
  --policy-name blog-portfolio-terraform-cloud-policy \
  --policy-document file://terraform-cloud-policy.json

# Detach AdministratorAccess and attach custom policy
aws iam detach-role-policy \
  --role-name blog-portfolio-terraform-cloud-role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

aws iam attach-role-policy \
  --role-name blog-portfolio-terraform-cloud-role \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/blog-portfolio-terraform-cloud-policy
```

## Troubleshooting

### Common Issues

1. **"No valid credential sources found"**
   - Check that `TFC_AWS_PROVIDER_AUTH` is set to `true`
   - Verify the role ARN is correct

2. **"Access Denied" when assuming role**
   - Check the trust policy conditions
   - Verify your Terraform Cloud organization name is correct
   - Ensure the workspace name matches

3. **"Invalid identity token"**
   - Check the OIDC provider thumbprint
   - Verify the audience is set to `aws.workload.identity`

### Verification Commands

```bash
# Verify OIDC provider exists
aws iam list-open-id-connect-providers

# Verify role exists
aws iam get-role --role-name blog-portfolio-terraform-cloud-role

# Test role assumption (from Terraform Cloud run)
aws sts get-caller-identity
```

## Cleanup

If you need to remove the manually created resources:

```bash
# Detach policies
aws iam detach-role-policy \
  --role-name blog-portfolio-terraform-cloud-role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Delete role
aws iam delete-role --role-name blog-portfolio-terraform-cloud-role

# Delete OIDC provider
aws iam delete-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/app.terraform.io
```

---

Once this manual setup is complete, Terraform Cloud will be able to manage all your other AWS resources automatically!