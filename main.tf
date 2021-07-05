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
module "aws_lambda" {
  source     = "./modules/terraform-aws-lambda"
  client     = "blevk"
  env        = "prod"
  project    = "grootbot"

  filename   = "lambda_function.zip"
  timeout    = 15
  source_arn = module.aws_api_gateway.api_gateway_execution_arn
  
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

module "aws_api_gateway" {
  source     = "./modules/terraform-aws-api-gateway"
  client     = "blevk"
  env        = "prod"
  project    = "grootbot"

  path       = "lambda"
  method     = "ANY"
  type       = "AWS_PROXY"
  lambda_arn = module.aws_lambda.lambda_arn
}

module "aws_dynamodb" {
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

module "aws_iot" {
  source     = "./modules/terraform-aws-iot"
  client     = "blevk"
  env        = "prod"
  project    = "grootbot"

  description_rule = "Save data from sensors to DynamoDB"
  sql              = "SELECT *, trunc((timestamp() / 1E3), 0) as Timestamp FROM 'grootbot/sensors'"
  table_name       = module.aws_dynamodb.table_name
  table_arn        = module.aws_dynamodb.dynamodb_arn
  certificate_path = "./certificate/"

  attributes = {
    Owner = "blevk"
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "curl --silent https://api.telegram.org/bot${var.token}/setWebhook?url=${module.aws_api_gateway.invoke_url}"
  }
}
