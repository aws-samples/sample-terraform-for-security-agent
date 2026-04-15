# AWS Security Agent Resources

# Wait for IAM roles to propagate before creating resources
resource "time_sleep" "wait_for_iam" {
  depends_on = [
    aws_iam_role.app_role,
    aws_iam_role_policy_attachment.app_role_policy,
    aws_iam_role.service_role,
    aws_iam_role_policy.service_role_permissions
  ]

  create_duration = "15s"
}

# Application — one per account, links the app role to the service
resource "awscc_securityagent_application" "this" {
  depends_on = [time_sleep.wait_for_iam]
}

# Agent Space — central workspace for pentests
resource "awscc_securityagent_agent_space" "this" {
  name        = var.agent_space_name
  description = var.agent_space_description

  aws_resources = {
    iam_roles = [aws_iam_role.service_role.arn]
  }

  tags = [
    for key, value in var.tags : {
      key   = key
      value = value
    }
  ]

  depends_on = [awscc_securityagent_application.this]
}

# Target Domain — register a domain for pentest (optional)
resource "awscc_securityagent_target_domain" "this" {
  count = var.target_domain != "" ? 1 : 0

  target_domain_name  = var.target_domain
  verification_method = var.target_domain_verification_method
}

# Pentest — pentest configuration
# Note: Pentest creation via AWSCC/CloudFormation may experience timeouts.
# If this happens, use the AWS CLI instead (see post-deploy.sh for examples).
resource "awscc_securityagent_pentest" "this" {
  count = var.create_pentest ? 1 : 0

  agent_space_id = awscc_securityagent_agent_space.this.agent_space_id
  title          = var.pentest_title
  service_role   = aws_iam_role.service_role.arn

  assets = {
    endpoints = [
      for uri in var.target_endpoints : {
        uri = uri
      }
    ]
  }

  depends_on = [awscc_securityagent_agent_space.this]
}
