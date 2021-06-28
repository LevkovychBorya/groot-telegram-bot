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
variable "filename" {
  type    = string
  default = "lambda_function.zip"
  description = "Path to the function's deployment package within the local filesystem."
}
variable "handler" {
  type    = string
  default = "lambda_handler"
  description = "Function entrypoint in your code."
}
variable "timeout" {
  type    = number
  default = 3
  description = "Amount of time your Lambda Function has to run in seconds."
}
variable "runtime" {
  type    = string
  default = "python3.8"
  description = "Identifier of the function's runtime."
}
variable "variables" {
  type    = map(any)
  default = {
      foo = "bar"
  }
  description = "Map of environment variables that are accessible from the function code during execution."
}
variable "tags" {
  type    = map(any)
  default = {
      "foo" = "bar"
  }
  description = "Map of tags to assign to the lambda function."
}
variable "policy" {
    type = string
    default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:*",
      "Effect": "Deny",
      "Resource": "*"
    }
  ]
}
EOF
    description = "The policy document. This is a JSON formatted string."
}