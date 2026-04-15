#!/bin/bash

# Post-deployment verification script for AWS Security Agent

set -e

echo "🔍 AWS Security Agent Post-Deployment Verification"
echo "==================================================="

echo "📋 Getting Terraform outputs..."

AGENT_SPACE_ID=$(terraform output -raw agent_space_id 2>/dev/null || echo "")

if [ -z "$AGENT_SPACE_ID" ]; then
    echo "❌ Could not get Agent Space ID from Terraform outputs"
    echo "   Make sure Terraform has been applied successfully"
    exit 1
fi

APP_ID=$(terraform output -raw application_id 2>/dev/null || echo "")
APP_ROLE_ARN=$(terraform output -raw app_role_arn 2>/dev/null || echo "")
SERVICE_ROLE_ARN=$(terraform output -raw service_role_arn 2>/dev/null || echo "")
PENTEST_ID=$(terraform output -raw pentest_id 2>/dev/null || echo "")
REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")

echo "✅ Application ID:     $APP_ID"
echo "✅ Agent Space ID:     $AGENT_SPACE_ID"
echo "✅ App Role ARN:       $APP_ROLE_ARN"
echo "✅ Service Role ARN:   $SERVICE_ROLE_ARN"
[ -n "$PENTEST_ID" ] && echo "✅ Pentest ID:         $PENTEST_ID"

echo ""
echo "🔍 Verify your setup:"
echo "aws securityagent list-agent-spaces --region $REGION"
echo ""
echo "aws securityagent batch-get-agent-spaces --agent-space-ids $AGENT_SPACE_ID --region $REGION"

if [ -n "$PENTEST_ID" ]; then
    echo ""
    echo "📋 Pentest commands:"
    echo ""
    echo "# Start a pentest job:"
    echo "aws securityagent start-pentest-job \\"
    echo "  --agent-space-id $AGENT_SPACE_ID \\"
    echo "  --pentest-id $PENTEST_ID \\"
    echo "  --region $REGION"
    echo ""
    echo "# List pentest jobs:"
    echo "aws securityagent list-pentest-jobs-for-pentest \\"
    echo "  --agent-space-id $AGENT_SPACE_ID \\"
    echo "  --pentest-id $PENTEST_ID \\"
    echo "  --region $REGION"
    echo ""
    echo "# Stop a running pentest job:"
    echo "# aws securityagent stop-pentest-job \\"
    echo "#   --agent-space-id $AGENT_SPACE_ID \\"
    echo "#   --pentest-job-id <JOB_ID> \\"
    echo "#   --region $REGION"
fi

echo ""
echo "📋 Access the Security Agent console at:"
echo "   https://console.aws.amazon.com/securityagent/"
