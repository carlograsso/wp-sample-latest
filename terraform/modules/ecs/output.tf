output "cluster_id" {
  value = aws_ecs_cluster.this
}

output "ecs_service" {
  value = aws_ecs_service.this
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.this.arn
}