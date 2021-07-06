data "aws_secretsmanager_secret_version" "token" {
  secret_id = "TeleToken"
}