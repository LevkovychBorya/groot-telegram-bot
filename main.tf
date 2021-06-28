# Configuration of the provider and backend
provider "aws" {
  region  = "eu-central-1"
}

terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket = "grootbot-terraform-bucket"
    key    = "grootbot.tfstate"
    region = "eu-central-1"
    encrypt = true
  }
}

# Infrastructure as a code
module "lambda" {
  source = "./modules/terraform-aws-lambda"
  client = "blevk"
  env    = "prod"
  project = "grootbot"
  filename = "lambda_function.zip"
  timeout = 5
  variables = {
    TELEGRAM_TOKEN = "token"
  }
  tags = {
    "Owner" = "blevk"
  } 
  policy = <<EOF
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
}
