variable "project_name" {
  type    = string
  default = "ministack"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type      = string
  default   = "changeme123"
  sensitive = true
}
