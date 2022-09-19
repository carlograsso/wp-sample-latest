variable "name" {}

variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "main_listener" {}
variable "main_target_group" {}
variable "dev_listener" {}
variable "dev_target_group" {}
variable "termination_wait_time_in_minutes" {}
variable "deployment_config_name" {}
variable "image_name" {}


variable "codebuild_params" {
  type = map(string)
}

variable "environment_variables" {
  type = map(string)
}

variable "ci_cd_source_repo_name" {}
variable "ci_cd_source_repo_owner" {}
variable "ci_cd_source_repo_branch" {}
variable "ci_cd_source_repo_token" {}