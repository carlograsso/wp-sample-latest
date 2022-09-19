variable "security_groups" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "name" {
  type = string
}

variable "container_port" {
  type = number
}
