output "role_ecs_task_arn" {
  value = aws_iam_role.ecs_task.arn
}

output "role_ecs_execution_arn" {
  value = aws_iam_role.ecs_execution.arn
}