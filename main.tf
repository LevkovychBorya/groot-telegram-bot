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
  source     = "./modules/terraform-aws-lambda"
  client     = "blevk"
  env        = "prod"
  project    = "grootbot"

  filename   = "lambda_function.zip"
  timeout    = 15
  source_arn = module.api_gateway.api_gateway_execution_arn
  
  variables  = {
    TELEGRAM_TOKEN = "token"
  }

  tags = {
    "Owner"  = "blevk"
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1625173905105",
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

module "api_gateway" {
  source     = "./modules/terraform-aws-api-gateway"
  client     = "blevk"
  env        = "prod"
  project    = "grootbot"

  path       = "lambda"
  method     = "ANY"
  type       = "AWS_PROXY"
  lambda_arn = module.lambda.lambda_arn
}

module "dynamodb" {
  source     = "./modules/terraform-aws-dynamodb"
  client     = "blevk"
  env        = "prod"
  project    = "grootbot"

  read_capacity  = 1
  write_capacity = 1
  hash_key       = "SerialNumber"
  range_key      = "Timestamp"
  
  attributes = [
    {
      name = "SerialNumber"
      type = "S"
    },
    {
      name = "Timestamp"
      type = "N"
    }
  ]

  #Mock data:
  /*{
  "Humidity": 40,
  "Light": 50,
  "Moisture": 0,
  "SerialNumber": "10000000cc67568b",
  "Temperature": 22,
  "Timestamp": 1622628889
  }*/
  
  tags = {
    "Owner"  = "blevk"
  } 
}
