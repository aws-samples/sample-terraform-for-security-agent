# AWS Security Agent Terraform Configuration
# Provisions IAM roles, an application, agent spaces, and pentests

provider "awscc" {
  region = var.aws_region
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
