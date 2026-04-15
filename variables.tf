# Variables for AWS Security Agent Configuration

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "agent_space_name" {
  description = "Name for the Security Agent agent space"
  type        = string
  default     = "MySecurityAgentSpace"
}

variable "agent_space_description" {
  description = "Description for the agent space"
  type        = string
  default     = "Agent space for pentests"
}

variable "create_pentest" {
  description = "Whether to create a pentest"
  type        = bool
  default     = false
}

variable "pentest_title" {
  description = "Title for the pentest (letters, numbers, hyphens, underscores only, max 100 chars)"
  type        = string
  default     = "My-Pentest"
}

variable "target_endpoints" {
  description = "List of target endpoint URIs to assess"
  type        = list(string)
  default     = []
}

variable "target_domain" {
  description = "Domain to register for verification (leave empty to skip)"
  type        = string
  default     = ""
}

variable "target_domain_verification_method" {
  description = "Verification method for the target domain (DNS_TXT or HTTP_ROUTE)"
  type        = string
  default     = "DNS_TXT"
}

variable "name_postfix" {
  description = "Postfix for IAM role names to ensure uniqueness"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "aws-security-agent"
  }
}
