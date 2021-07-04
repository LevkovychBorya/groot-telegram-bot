terraform {
  required_version = ">= 1.0.0"
}

resource "aws_dynamodb_table" "this" {
  name           = format("%s-%s-%s-table", var.client, var.env, var.project)
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  range_key      = var.range_key

  dynamic "attribute" {
    for_each = var.attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  tags = var.tags
}