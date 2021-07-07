data "aws_secretsmanager_secret_version" "token" {
  secret_id = "TeleToken"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "./source"
  output_path = "./lambda_function.zip"

  depends_on = [null_resource.zip]
}