data "aws_iam_policy_document" "assume_role" {
  provider = aws.destination
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity"
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::<ACCOUNT_ID>:role/role_for_lambda"]
    }
  }
}

resource "aws_iam_policy" "lambda_custom_policy" {
  name        = "management_account_actions"
  path        = "/"
  description = "IAM policy for lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses"
        ],
        "Resource": [
            "arn:aws:ec2:<REGION>:<ACCOUNT_ID>:instance/<instance-id>"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "assume_role" {
  name                = "management_assume_role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [aws_iam_policy.lambda_custom_policy.arn]
  tags                = {}
}