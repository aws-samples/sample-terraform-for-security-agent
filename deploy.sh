#!/bin/bash

# AWS Security Agent Terraform Deployment Script

set -e

echo "🚀 AWS Security Agent Terraform Deployment"
echo "============================================"

echo "📋 Checking prerequisites..."

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform first."
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install AWS CLI first."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

if [ ! -f "terraform.tfvars" ]; then
    echo "📝 Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    echo "✅ Please edit terraform.tfvars with your configuration, then run this script again."
    exit 0
fi

echo "🔧 Initializing Terraform..."
terraform init

echo "🔍 Validating configuration..."
terraform validate

echo "📋 Planning deployment..."
terraform plan -out=tfplan

echo ""
read -p "🤔 Do you want to apply this plan? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    rm -f tfplan
    exit 0
fi

echo "🚀 Applying deployment..."
if terraform apply tfplan; then
    echo "✅ Deployment successful!"
else
    echo "❌ Deployment failed. Check the errors above."
    rm -f tfplan
    exit 1
fi

rm -f tfplan

echo ""
echo "🎉 Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "1. Note the agent_space_id and app_role_arn from the outputs above"
echo "2. Visit https://console.aws.amazon.com/securityagent/ to access the console"
echo "3. To create a pentest, set create_pentest=true in terraform.tfvars"
echo "4. Run './deploy.sh' again to add the pentest"
