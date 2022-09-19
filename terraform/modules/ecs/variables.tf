variable "name" {
  type = string
}

variable "capacity_providers" {
  type = list(string)
}

variable "service" {
  type = object({
    desired_count    = number
    target_group_arn = string
    container_port   = number
    subnets          = list(string)
    security_groups  = list(string)
  })
}

variable "task" {
  type = object({
    name                     = string
    image_url                = string
    network_mode             = string
    requires_compatibilities = list(string)
    cpu                      = number
    memory                   = number
    execution_role_arn       = string
    task_role_arn            = string
    environment              = any
    source_volume            = string
    container_path           = string
    container_port           = number
    db_password_secret_arn   = string
  })
}

variable "volume" {
  type = object({
    name            = string
    file_system_id  = string
    root_directory  = string
    access_point_id = string
  })
}

variable "cpu_down_threshold" {
  type = number
}

variable "cpu_up_threshold" {
  type = number
}

variable "ecs_max_capacity" {
  type = number
}

variable "ecs_min_capacity" {
  type = number
}