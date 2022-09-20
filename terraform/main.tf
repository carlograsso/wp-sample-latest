module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.4"

  name = "${var.project}-${var.region}-${var.resource_name}"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  # database_subnets = var.database_subnets

  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
}

module "sgs" {
  source = "./modules/sgs"

  project = var.project
  vpc_id  = module.vpc.vpc_id
}

module "iam" {
  source                 = "./modules/iam"
  db_password_secret_arn = data.aws_secretsmanager_secret_version.db_password.arn

  project = var.project
}

module "efs" {
  source  = "./modules/efs"
  project = var.project

  name               = var.resource_name
  subnets            = module.vpc.private_subnets # SWICCIARE SU DB SUBNETS
  security_groups    = [module.sgs.sg_efs]
  efs_ap_path        = var.efs_ap_path
  owner_gid          = var.owner_gid
  owner_uid          = var.owner_uid
  user_gid           = var.user_gid
  user_uid           = var.user_uid
  efs_ap_permissions = 0775

  depends_on = [module.sgs, module.vpc]
}

module "db_serverless" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "7.5.1"

  name              = var.resource_name
  engine            = var.database_engine
  engine_mode       = "provisioned"
  engine_version    = var.database_engine_version
  storage_encrypted = true

  database_name = var.database_name

  create_random_password = false
  master_username        = var.database_username
  master_password        = data.aws_secretsmanager_secret_version.db_password.secret_string



  vpc_id                  = module.vpc.vpc_id
  subnets                 = module.vpc.private_subnets
  create_security_group   = true
  allowed_security_groups = [module.sgs.sg_ecs]

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = var.database_min_num
    max_capacity = var.database_max_num
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
    two = {}
  }

  depends_on = [module.vpc]
}

######################################################
resource "aws_route53_zone" "this" {
  name = var.r53_zone_name

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_record" "db_writer" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "wp-db-writer"
  type    = "CNAME"
  ttl     = "300"
  records = [module.db_serverless.cluster_endpoint]

  depends_on = [aws_route53_zone.this, module.db_serverless]
}

resource "aws_route53_record" "db_reader" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "wp-db-reader"
  type    = "CNAME"
  ttl     = "300"
  records = [module.db_serverless.cluster_reader_endpoint]

  depends_on = [aws_route53_zone.this, module.db_serverless]
}
######################################################

module "load_balancer" {
  source = "./modules/load_balancer"

  name = var.resource_name

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.sgs.sg_lb]
  container_port  = var.container_port

  depends_on = [module.vpc]
}

module "ecs_cluster" {
  source = "./modules/ecs"

  name               = var.resource_name
  capacity_providers = var.ecs_capacity_providers


  service = {
    desired_count    = 1
    container_port   = var.container_port
    target_group_arn = module.load_balancer.lb_target_group_main.arn #arrivato qui
    subnets          = module.vpc.private_subnets                    # mettere private subs
    security_groups  = [module.sgs.sg_ecs]
    container_port   = var.container_port
  }

  volume = {
    name            = "ecs-storage"
    root_directory  = "/"
    file_system_id  = module.efs.efs_file_system_id
    access_point_id = module.efs.efs_access_point_id

  }

  task = {
    name                     = var.resource_name
    image_url                = var.default_image_url
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = 256
    memory                   = 1024
    execution_role_arn       = module.iam.role_ecs_execution_arn
    task_role_arn            = module.iam.role_ecs_task_arn
    container_port           = var.container_port
    source_volume            = "ecs-storage"
    container_path           = var.container_path
    db_password_secret_arn   = data.aws_secretsmanager_secret_version.db_password.arn
    environment = {
      db_username = var.database_username
      db_host     = aws_route53_record.db_writer.fqdn
      db_name     = var.database_name
    }
  }
  ecs_max_capacity   = var.ecs_max_capacity
  ecs_min_capacity   = var.ecs_min_capacity
  cpu_up_threshold   = var.cpu_up_threshold
  cpu_down_threshold = var.cpu_down_threshold
}


###################### PIPELINES 

module "ci_cd" {
  source = "./modules/cicd/"

  name                     = var.resource_name
  ci_cd_source_repo_owner  = var.ci_cd_source_repo_owner
  ci_cd_source_repo_name   = var.ci_cd_source_repo_name
  ci_cd_source_repo_branch = var.ci_cd_source_repo_branch
  ci_cd_source_repo_token  = var.ci_cd_source_repo_token


  codebuild_params = {
    git_repo     = "https://github.com/carlograsso/wp-sample-final"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    cred_type    = "CODEBUILD"
  }
  image_name = var.image_name
  environment_variables = {
    AWS_REGION          = var.region
    AWS_ACCOUNT_ID      = data.aws_caller_identity.this.account_id
    IMAGE_REPO_NAME     = var.image_name
    IMAGE_TAG           = var.image_tag
    CONTAINER_NAME      = var.resource_name
    CONTAINER_PORT      = var.container_port
    SECURITY_GROUP      = module.sgs.sg_ecs
    TASK_DEFINITION_ARN = module.ecs_cluster.ecs_task_definition_arn
    TASK_DEFINITION     = "wp-application-task"
    EXEC_ROLE_ARN       = module.iam.role_ecs_execution_arn
    FAMILY              = "wp-application-task"
  }

  deployment_config_name = var.deployment_config_name
  ecs_service_name       = "${var.resource_name}-service"
  ecs_cluster_name       = var.resource_name
  main_listener          = module.load_balancer.lb_listener_main.id
  dev_listener           = module.load_balancer.lb_listener_dev.id

  main_target_group = module.load_balancer.lb_target_group_main.name
  dev_target_group  = module.load_balancer.lb_target_group_dev.name

  termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
}