# Variables to help format the name
variable "client" {
  type    = string
  default = "ajassy"
  description = "The name of the client"
}
variable "env" {
  type    = string
  default = "dev"
  description = "The name of the environment: dev/test/prod"
}
variable "project" {
  type    = string
  default = "phoenix"
  description = "The name of the project"
}

# Variables to change the module
variable "path" {
  type    = string
  default = "lambda"
  description = "The last path segment of this API resource."
}
variable "method" {
  type    = string
  default = "GET"
  description = " The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)"
}
variable "authorization" {
  type    = string
  default = "NONE"
  description = "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)"
}
variable "integration_method" {
  type    = string
  default = "POST"
  description = "The HTTP method (GET, POST, PUT, DELETE, HEAD, OPTION, ANY)"
}
variable "type" {
  type    = string
  default = "AWS_PROXY"
  description = "The integration input's type. Valid values are HTTP/MOCK/AWS/AWS_PROXY/HTTP_PROXY"
}
variable "lambda_arn" {
  type    = string
  default = "arn"
  description = "The input's URI. For AWS integrations, the URI should be in form of the arn"
}
