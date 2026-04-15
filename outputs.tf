# Outputs for AWS Security Agent Configuration

output "application_id" {
  description = "ID of the Security Agent application"
  value       = awscc_securityagent_application.this.application_id
}

output "agent_space_id" {
  description = "ID of the created agent space"
  value       = awscc_securityagent_agent_space.this.agent_space_id
}

output "agent_space_name" {
  description = "Name of the created agent space"
  value       = awscc_securityagent_agent_space.this.name
}

output "app_role_arn" {
  description = "ARN of the Security Agent application IAM role"
  value       = aws_iam_role.app_role.arn
}

output "service_role_arn" {
  description = "ARN of the penetration test service IAM role"
  value       = aws_iam_role.service_role.arn
}

output "pentest_id" {
  description = "ID of the created pentest"
  value       = var.create_pentest ? awscc_securityagent_pentest.this[0].pentest_id : null
}

output "target_domain_id" {
  description = "ID of the registered target domain"
  value       = var.target_domain != "" ? awscc_securityagent_target_domain.this[0].target_domain_id : null
}

output "target_domain_verification_status" {
  description = "Verification status of the target domain"
  value       = var.target_domain != "" ? awscc_securityagent_target_domain.this[0].verification_status : null
}

output "target_domain_verification_details" {
  description = "Verification details (DNS TXT or HTTP route) for the target domain"
  value       = var.target_domain != "" ? awscc_securityagent_target_domain.this[0].verification_details : null
}

output "primary_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}
