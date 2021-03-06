output "api_gateway_execution_arn" {
  value = "${aws_api_gateway_rest_api.this.execution_arn}/*/${aws_api_gateway_method.this.http_method}${aws_api_gateway_resource.this.path}"
}

output "invoke_url" {
  value = "${aws_api_gateway_stage.this.invoke_url}/${var.path}"
}