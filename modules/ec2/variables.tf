variable "project_name"   { type = string }
variable "vpc_id"          { type = string }
variable "subnet_id"       { type = string }
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_count" {
  type    = number
  default = 1
}
variable "ami_id" {
  type    = string
  default = "ami-0c55b159cbfafe1f0"
}
