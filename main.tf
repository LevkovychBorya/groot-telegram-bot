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

  filename         = data.archive_file.source.output_path
  timeout          = 15
  source_arn       = module.aws_api_gateway.api_gateway_execution_arn
  source_code_hash = data.archive_file.source.output_base64sha256

  variables  = {
    telegram_token = "${data.aws_secretsmanager_secret_version.token.secret_string}"
    table_name     = "${module.aws_dynamodb.table_name}"
    thing_name     = "${module.aws_iot.thing_name}"
    shadow_name    = "GrootShadow"
    serial_number  = "10000000cc67568b"
    authorised_ids = "['380902776', '390672933']"
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
  certificate_path = "./certificate"

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

# Set webhook for the bot. Whenever there is an update for the bot, it will send an HTTPS POST request to the specified url.
resource "null_resource" "webhook" {
  provisioner "local-exec" {
    command = "curl --silent https://api.telegram.org/bot${data.aws_secretsmanager_secret_version.token.secret_string}/setWebhook?url=${module.aws_api_gateway.invoke_url}"
  }
}

# Download libraries from requirements.txt and zip it.
resource "null_resource" "zip" {
  triggers = {
    main         = "${base64sha256(file("./source/lambda_function.py"))}"
    requirements = "${base64sha256(file("./source/requirements.txt"))}"
  }
  provisioner "local-exec" {
    command = "python -m pip install --platform manylinux1_x86_64 --only-binary=:all: --no-binary=:none: -r source/requirements.txt -t source"
  }
}
