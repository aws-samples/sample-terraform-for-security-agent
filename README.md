# AWS Security Agent Terraform Configuration

This Terraform configuration demonstrates how to provision [AWS Security Agent](https://docs.aws.amazon.com/securityagent/) resources using the [AWSCC Terraform provider](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs).

> **Note:** This is sample code for demonstration purposes. Review and adapt it to meet your organization's security and compliance requirements before deploying to production.

## Overview

AWS Security Agent helps you analyze web applications for security risks through automated design reviews, code reviews, and penetration testing. This configuration automates the setup described in the [getting started guide](https://docs.aws.amazon.com/securityagent/latest/userguide/setup-security-agent.html).

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- An AWS account with permissions to create IAM roles and Security Agent resources

## What this guide covers

- **Part 1** — Deploy the application, IAM roles, and an agent space. After completing this part, you can access the Security Agent console and web application.
- **Part 2 (Optional)** — Register a target domain for verification.
- **Part 3 (Optional)** — Create a pentest with target endpoints.

## Resources Created

### Part 1: Application and Agent Space

| Resource | Name | Purpose |
|----------|------|---------|
| Application | One per account | Represents the Security Agent web application with its domain and application role |
| IAM Role | SecurityAgentAppRole-* | Application role with `AWSSecurityAgentWebAppPolicy` managed policy |
| IAM Role | SecurityAgentServiceRole-* | Penetration test service role with inline permissions for IAM and CloudWatch Logs |
| Agent Space | Configurable | Central workspace for pentests |

### Part 2: Target Domain (Optional)

| Resource | Name | Purpose |
|----------|------|---------|
| Target Domain | Configurable | Domain registered for verification |

### Part 3: Pentest (Optional)

| Resource | Name | Purpose |
|----------|------|---------|
| Pentest | Configurable | Pentest with target endpoints |

## Usage

### Part 1: Deploy the Application and Agent Space

1. **Clone and configure**
   ```bash
   git clone <this-repo>
   cd sample-terraform-for-security-agent
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`** with your agent space name and description.

3. **Deploy**
   ```bash
   ./deploy.sh
   ```
   Or manually:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Record the outputs** — note the `agent_space_id` and `app_role_arn` values.

5. **Verify**
   ```bash
   ./post-deploy.sh
   ```

### Part 2 (Optional): Register a Target Domain

Before running pentests, you must register and verify ownership of your target domain. Verification can be done via DNS TXT record or HTTP route. See [Enable test domain](https://docs.aws.amazon.com/securityagent/latest/userguide/enable-test-domain.html) for details.

1. **Set the target domain** in `terraform.tfvars`:
   ```hcl
   target_domain = "your-domain.example.com"
   ```

   You can also choose the verification method (`DNS_TXT` or `HTTP_ROUTE`, default is `DNS_TXT`):
   ```hcl
   target_domain_verification_method = "DNS_TXT"
   ```

2. **Deploy**:
   ```bash
   terraform apply
   ```

   Terraform creates the target domain and returns verification details. Check the outputs:
   ```bash
   terraform output target_domain_verification_details
   ```

3. **Update your domain** with the verification token:
   - For `DNS_TXT`: Add a TXT record to your DNS with the `token` value at the `dns_record_name`.
   - For `HTTP_ROUTE`: Serve the `token` value at the `route_path` on your domain.

4. **Verify** — once the DNS record or HTTP route is in place, verify the domain:
   ```bash
   aws securityagent verify-target-domain \
     --target-domain-id <TARGET_DOMAIN_ID> \
     --region <REGION>
   ```
   The domain must reach `VERIFIED` status before it can be used in pentests.

### Part 3 (Optional): Create a Pentest

1. **Set the pentest variables** in `terraform.tfvars`:
   ```hcl
   create_pentest   = true
   pentest_title    = "Q2-Security-Review"
   target_endpoints = ["https://your-domain.example.com"]
   ```

2. **Deploy again**:
   ```bash
   terraform apply
   ```

## Configuration Options

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `agent_space_name` | Name for the agent space | `MySecurityAgentSpace` |
| `agent_space_description` | Description for the agent space | `Agent space for pentests` |
| `create_pentest` | Whether to create a pentest | `false` |
| `pentest_title` | Title for the pentest | `My-Pentest` |
| `target_endpoints` | List of endpoint URIs to assess | `[]` |
| `target_domain` | Domain to register | `""` |
| `target_domain_verification_method` | Verification method (`DNS_TXT` or `HTTP_ROUTE`) | `DNS_TXT` |
| `name_postfix` | Postfix for IAM role names | `""` |
| `tags` | Tags for all resources | See `variables.tf` |

## IAM Roles

This configuration creates two IAM roles:

- **Application Role** — Trusted by `securityagent.amazonaws.com`. Uses the [`AWSSecurityAgentWebAppPolicy`](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSSecurityAgentWebAppPolicy.html) managed policy (`arn:aws:iam::aws:policy/service-role/AWSSecurityAgentWebAppPolicy`). The Security Agent service assumes this role to grant web application users permissions to interact with Security Agent APIs.

- **Penetration Test Service Role** — Trusted by `securityagent.amazonaws.com` with source account condition. Has an inline policy granting `iam:GetRole`, `iam:SimulatePrincipalPolicy`, `logs:CreateLogGroup`, `logs:CreateLogStream`, and `logs:PutLogEvents`. The service assumes this role to access your AWS resources during penetration testing.

For more details, see [Create an IAM Role for AWS Security Agent](https://docs.aws.amazon.com/securityagent/latest/userguide/create-iam-role.html).

## Cleanup

```bash
./cleanup.sh
```
Or manually:
```bash
terraform destroy
```

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the MIT-0 License. See the [LICENSE](LICENSE) file for details.
