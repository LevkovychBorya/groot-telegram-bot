terraform {
  required_version = "> 1.0.0"
}

module "lambda" {
  source = "./modules/terraform-aws-lambda"
  client = "blevk"
  env    = "prod"
  project = "grootbot"
  filename = "lambda_function.zip"
  timeout = 5
  varialbes = {
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
