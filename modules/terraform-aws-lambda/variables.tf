# Variables to help format the name
variable "client" {
  description = "The name of the client"
  type    = string
  default = "ajassy"
}
variable "env" {
  description = "The name of the environment: dev/test/prod"
  type    = string
  default = "dev"
}
variable "project" {
  description = "The name of the project"
  type    = string
  default = "phoenix"
}

# Variables to change the module
variable "filename" {
  description = "Path to the function's deployment package within the local filesystem."
  type    = string
  default = "lambda_function.zip"
}
variable "handler" {
  description = "Function entrypoint in your code."
  type    = string
  default = "lambda_function.lambda_handler"
}
variable "timeout" {
  description = "Amount of time your Lambda Function has to run in seconds."
  type    = number
  default = 3
}
variable "runtime" {
  description = "Identifier of the function's runtime."
  type    = string
  default = "python3.8"
}
variable "variables" {
  description = "Map of environment variables that are accessible from the function code during execution."
  type    = map(any)
}
variable "tags" {
  description = "Map of tags to assign to the lambda function."
  type    = map(any)
}
variable "policy" {
  description = "The policy document. This is a JSON formatted string."
  type = string
}
variable "statement_id" {
  description = "A unique statement identifier."
  type    = string
  default = "AllowExecutionFromAPIGateway"
}
variable "action" {
  description = "The AWS Lambda action you want to allow in this statement."
  type    = string
  default = "lambda:InvokeFunction"
}
variable "principal" {
  description = "The principal who is getting this permission."
  type    = string
  default = "apigateway.amazonaws.com"
}
variable "source_arn" {
  description = "When the principal is an AWS service, the ARN of the specific resource within that service to grant permission to."
  type    = string
}