terraform {
  required_version = ">= 1.0.0"
}

resource "aws_api_gateway_rest_api" "this" {
  name = format("%s-%s-%s-api", var.client, var.env, var.project)
}

resource "aws_api_gateway_resource" "this" {
  path_part   = var.path
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = var.method
  authorization = var.authorization
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = var.integration_method
  type                    = var.type
  uri                     = var.lambda_arn
}