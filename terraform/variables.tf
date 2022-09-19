variable "project" {}
variable "region" {}
variable "resource_name" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "private_subnets" {}
variable "public_subnets" {}

variable "efs_ap_path" {}
variable "owner_gid" {}
variable "owner_uid" {}
variable "user_gid" {}
variable "user_uid" {}
variable "efs_ap_permissions" {}

variable "database_name" {}
variable "database_username" {}
variable "database_min_num" {}
variable "database_max_num" {}
variable "database_engine" {}
variable "database_engine_version" {}
variable "db_password_secret_name" {}

variable "ecs_capacity_providers" {}
variable "container_port" {}
variable "container_path" {}
variable "image_name" {}
variable "image_tag" {}
variable "default_image_url" {}

variable "deployment_config_name" {}
variable "termination_wait_time_in_minutes" {}

variable "ecs_max_capacity" {}
variable "ecs_min_capacity" {}
variable "cpu_up_threshold" {}
variable "cpu_down_threshold" {}

variable "ci_cd_source_repo_name" {}
variable "ci_cd_source_repo_owner" {}
variable "ci_cd_source_repo_branch" {}
variable "ci_cd_source_repo_token" {}