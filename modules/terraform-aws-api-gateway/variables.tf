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
variable "path" {
  description = "The last path segment of this API resource."
  type    = string
  default = "lambda"
}
variable "method" {
  description = " The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)"
  type    = string
  default = "GET"
}
variable "authorization" {
  description = "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)"
  type    = string
  default = "NONE"
}
variable "integration_method" {
  description = "The HTTP method (GET, POST, PUT, DELETE, HEAD, OPTION, ANY) Lambda function can only be invoked via POST."
  type    = string
  default = "POST"
}
variable "type" {
  description = "The integration input's type. Valid values are HTTP/MOCK/AWS/AWS_PROXY/HTTP_PROXY"
  type    = string
  default = "AWS_PROXY"
}
variable "lambda_arn" {
  description = "The input's URI. For AWS integrations, the URI should be in form of the arn"
  type    = string
}
variable "stage_name" {
  description = "Name of the stage to create with this deployment."
  type    = string
  default = "V1"
}
