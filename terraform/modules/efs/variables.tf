variable "project" {
  type = string
}

variable "name" {
  type = string
}


variable "efs_ap_path" {
  type = string
}

variable "owner_gid" {
  type = number
}

variable "owner_uid" {
  type = number
}

variable "user_gid" {
  type = number
}


variable "user_uid" {
  type = number
}


variable "efs_ap_permissions" {
  type = number
}

variable "subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}