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
variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity. The valid values are PROVISIONED and PAY_PER_REQUEST."
  type    = string
  default = "PROVISIONED"
}

variable "read_capacity" {
  description = "The number of read units for this table."
  type    = number
  default = 5
}

variable "write_capacity" {
  description = "The number of write units for this table."
  type    = number
  default = 5
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key."
  type    = string
  default = "UserId"
}

variable "range_key" {
  description = "The attribute to use as the range (sort) key."
  type    = string
  default = "GameTitle"
}

variable "attributes" {
  description = "Map of attributes for dynamodb table with their types."
}

variable "tags" {
  description = "Map of tags to assign to the dynamodb table."
  type    = map(any)
}