resource "aws_ecs_cluster" "this" {
  name = var.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 100
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.name}"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-task"
  network_mode             = var.task.network_mode
  requires_compatibilities = var.task.requires_compatibilities
  cpu                      = var.task.cpu
  memory                   = var.task.memory
  container_definitions    = data.template_file.task_definition.rendered

  execution_role_arn = var.task.execution_role_arn
  task_role_arn      = var.task.task_role_arn


  volume {
    name = var.volume.name
    efs_volume_configuration {
      file_system_id          = var.volume.file_system_id
      root_directory          = var.volume.root_directory
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999

      authorization_config {
        access_point_id = var.volume.access_point_id
      }
    }
  }
}

resource "aws_ecs_service" "this" {
  name             = "${var.name}-service"
  cluster          = aws_ecs_cluster.this.id
  task_definition  = aws_ecs_task_definition.this.arn
  desired_count    = var.service.desired_count
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = var.service.target_group_arn
    container_name   = var.name
    container_port   = var.service.container_port
  }

  network_configuration {
    subnets         = var.service.subnets
    security_groups = var.service.security_groups
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }



  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 100
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

}
 

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.ecs_max_capacity # TODO CAPACITY
  min_capacity       = var.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "upscale" {
  name               = "${var.name}-app-scale-up"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.name}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = var.cpu_up_threshold # TODO THRESHOLD

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.upscale.arn]
}


resource "aws_appautoscaling_policy" "downscale" {
  name               = "${var.name}-scale-down"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.cpu_down_threshold # TODO THRESHOLD

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.downscale.arn]
}
