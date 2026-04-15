# IAM Roles for AWS Security Agent

# Random suffix for unique role names
resource "random_id" "suffix" {
  byte_length = 4
}

# ---------------------------------------------------------------------------
# Application Role
# The Security Agent service assumes this role to grant WebApp users
# permissions to interact with Security Agent APIs.
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "app_role_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["securityagent.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "app_role" {
  name               = "SecurityAgentAppRole-${var.name_postfix != "" ? var.name_postfix : random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.app_role_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "app_role_policy" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSSecurityAgentWebAppPolicy"
}

# ---------------------------------------------------------------------------
# Penetration Test Service Role
# The Security Agent service assumes this role to access your AWS resources
# during penetration testing. Required for creating pentests.
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "service_role_trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["securityagent.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "service_role" {
  name               = "SecurityAgentServiceRole-${var.name_postfix != "" ? var.name_postfix : random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.service_role_trust.json
  description        = "Penetration test service role for AWS Security Agent"
  tags               = var.tags
}

data "aws_iam_policy_document" "service_role_permissions" {
  statement {
    sid    = "AllowIAMReadAndSimulate"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:SimulatePrincipalPolicy"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "service_role_permissions" {
  name   = "SecurityAgentServiceRolePolicy"
  role   = aws_iam_role.service_role.id
  policy = data.aws_iam_policy_document.service_role_permissions.json
}
