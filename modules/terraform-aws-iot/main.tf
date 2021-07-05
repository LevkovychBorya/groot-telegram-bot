terraform {
  required_version = ">= 1.0.0"
}

resource "aws_iot_thing" "this" {
  name = format("%s-%s-%s-thing", var.client, var.env, var.project)
  attributes = var.attributes
}

resource "aws_iot_certificate" "this" {
  active = true
}

resource "aws_iot_policy" "this" {
  name = format("%s-%s-%s-policy", var.client, var.env, var.project)
  policy = var.policy
}

resource "aws_iot_policy_attachment" "this" {
  policy = aws_iot_policy.this.name
  target = aws_iot_certificate.this.arn
}

resource "aws_iot_thing_principal_attachment" "this" {
  principal = aws_iot_certificate.this.arn
  thing     = aws_iot_thing.this.name
}

resource "aws_iot_topic_rule" "this" {
  name        = format("%s_%s_%s_rule", var.client, var.env, var.project)
  description = var.description_rule
  enabled     = var.enabled_rule
  sql         = var.sql
  sql_version = var.sql_version

  dynamodbv2 {
    put_item {
      table_name = var.table_name
    }
    role_arn = aws_iam_role.this.arn
  }
}

resource "aws_iam_role" "this" {
  name = format("%s_%s_%s_iot_rule_role", var.client, var.env, var.project)

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "iot.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  name = format("%s-%s-%s-iot-rule-policy", var.client, var.env, var.project)
  role = aws_iam_role.this.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "dynamodb:PutItem"
        ],
        "Resource": "${var.table_arn}"
    }
  ]
}
EOF
}

resource "local_file" "certificate" {
    content     = aws_iot_certificate.this.certificate_pem
    filename    = "${var.certificate_path}/certificate.pem"
}

resource "local_file" "private_key" {
    content     = aws_iot_certificate.this.private_key
    filename    = "${var.certificate_path}/private.key"
}

resource "local_file" "public_key" {
    content     = aws_iot_certificate.this.public_key
    filename    = "${var.certificate_path}/public.key"
}

resource "local_file" "endpoint" {
    content     = data.aws_iot_endpoint.this.endpoint_address
    filename    = "${var.certificate_path}/endpoint.txt"
}