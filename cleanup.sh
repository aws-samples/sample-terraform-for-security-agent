#!/bin/bash

# AWS Security Agent Terraform Cleanup Script

set -e

echo "🧹 AWS Security Agent Terraform Cleanup"
echo "========================================"

if [ ! -f "terraform.tfstate" ]; then
    echo "❌ No Terraform state found. Nothing to clean up."
    exit 0
fi

echo "🔍 Planning destruction..."
terraform plan -destroy

echo ""
echo "⚠️  WARNING: This will destroy all AWS Security Agent resources!"
echo "   - Application and agent space"
echo "   - IAM roles and policies"
echo "   - Pentests and target domains"
echo ""
read -p "🤔 Are you sure you want to destroy everything? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

echo ""
read -p "🚨 Last chance! Type 'DESTROY' to confirm: " confirm
if [ "$confirm" != "DESTROY" ]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

echo "🧹 Destroying resources..."
terraform destroy -auto-approve

echo ""
echo "✅ Cleanup completed successfully!"
echo "   All AWS Security Agent resources have been removed."
