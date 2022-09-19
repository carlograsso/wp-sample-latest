resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
  depends_on = [aws_lb_target_group.main]
}

resource "aws_lb_target_group" "main" {
  name        = "${var.name}-main"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  depends_on = [
    aws_lb.this
  ]
}

resource "aws_lb_listener" "dev" {
  load_balancer_arn = aws_lb.this.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev.arn
  }
  depends_on = [aws_lb_target_group.dev]
}

resource "aws_lb_target_group" "dev" {
  name        = "${var.name}-dev"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  depends_on = [
    aws_lb.this
  ]
}