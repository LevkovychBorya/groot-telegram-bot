# Variables to help format the name
variable "client" {
  description = "The name of the client"
  type    = string
  default = "ajassy"
}
variable "env" {
  description = "The name of the environment: dev/test/prod"
  type    = string
  default = "dev"
}
variable "project" {
  description = "The name of the project"
  type    = string
  default = "phoenix"
}

# Variables to change the module
variable "attributes" {
  description = "Map of attributes of the thing."
  type    = map(any)
}

variable "policy" {
  description = "The policy document. This is a JSON formatted string."
  type    = string
}

variable "description_rule" {
  description = "The description of the rule."
  type    = string
  default = "Default rule"
}

variable "enabled_rule" {
  description = "Specifies whether the rule is enabled."
  type    = bool
  default = true
}

variable "sql" {
  description = "The SQL statement used to query the topic."
  type    = string
  default = "SELECT * FROM 'topic/test'"
}

variable "sql_version" {
  description = "The version of the SQL rules engine to use when evaluating the rule."
  type    = string
  default = "2016-03-23"
}

variable "table_name" {
  description = "The name of dynamodb table."
  type    = string
}

variable "table_arn" {
  description = "The arn of dynamodb table."
  type    = string
}

variable "certificate_path" {
  description = "The arn of dynamodb table."
  type    = string
  default = "path.module"
}