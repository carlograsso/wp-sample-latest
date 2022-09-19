output "sg_lb" {
  value = aws_security_group.load_balancer.id
}

output "sg_efs" {
  value = aws_security_group.efs.id
}

output "sg_ecs" {
  value = aws_security_group.ecs.id
}
