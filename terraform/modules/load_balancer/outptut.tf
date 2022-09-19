output "load_balancer_endpoint" {
  value = aws_lb.this.dns_name
}

output "lb_target_group_main" {
  value = aws_lb_target_group.main
}

output "lb_target_group_dev" {
  value = aws_lb_target_group.dev
}

output "lb_listener_main" {
  value = aws_lb_listener.main
}

output "lb_listener_dev" {
  value = aws_lb_listener.dev
}

