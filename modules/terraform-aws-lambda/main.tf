terraform {
  required_version = ">= 1.0.0"
}

resource "aws_iam_role" "this" {
    name = format("%s-%s-%s-lambda-role", var.client, var.env, var.project)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "this" {
  filename      = var.filename
  function_name = format("%s-%s-%s-lambda-function", var.client, var.env, var.project)
  role          = aws_iam_role.this.arn
  handler       = var.handler
  timeout       = var.timeout

  source_code_hash = filebase64sha256(var.filename)

  runtime = var.runtime

  environment {
    variables = var.variables
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [source_code_hash, last_modified]
  }
}

resource "aws_iam_policy" "this" {
  name = format("%s-%s-%s-lambda-policy", var.client, var.env, var.project)

  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = var.statement_id
  action        = var.action
  function_name = aws_lambda_function.this.function_name
  principal     = var.principal
  source_arn    = var.source_arn
}