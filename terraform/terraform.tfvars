project       = "ourWordpress"
region        = "eu-west-1"
resource_name = "wp-application"

##### VPC
vpc_cidr        = "10.0.0.0/16"
azs             = ["eu-west-1a", "eu-west-1b"]     # , "eu-west-1c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]   #, "10.0.3.0/24"]
public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"] # , "10.0.13.0/24"]

##### FILESYSTEM
efs_ap_path        = "/wordpress"
owner_gid          = 1001
owner_uid          = 1001
user_gid           = 1001
user_uid           = 1001
efs_ap_permissions = 0775


#implemetare account id in init.sh

##### DATABASE
database_username = "username"

database_name           = "wordpress"
database_min_num        = 1
database_max_num        = 3
database_engine         = "aurora-mysql"
database_engine_version = "8.0.mysql_aurora.3.02.0"
database_instance_class = "db.t3.small"
db_password_secret_name = "wp-application-db-password"

##### ECS CLUSTER
default_image_url      = "docker.io/bitnami/wordpress:latest"
image_name             = "wp-image"
image_tag              = "latest"
ecs_capacity_providers = ["FARGATE SPOT", "FARGATE"]
container_port         = 8080
container_path         = "/bitnami/wordpress"

deployment_config_name           = "CodeDeployDefault.ECSAllAtOnce"
termination_wait_time_in_minutes = 5

ecs_max_capacity   = 3
ecs_min_capacity   = 1
cpu_up_threshold   = 70
cpu_down_threshold = 30

ci_cd_source_repo = "carlograsso/wp-sample-final"
ci_cd_source_branch = "developing"
ci_cd_source_detect_changes = false


