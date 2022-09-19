resource "aws_security_group" "load_balancer" {
  name   = "${var.project}-lb"
  vpc_id = var.vpc_id
}

resource "aws_security_group" "ecs" {
  name   = "${var.project}-ecs"
  vpc_id = var.vpc_id
}

resource "aws_security_group" "efs" {
  name   = "${var.project}-efs"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "storage_access_ecs" {
  description              = "EFS inbound access from ecs task sg"
  protocol                 = "tcp"
  from_port                = 2049
  to_port                  = 2049
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.ecs.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "storage_access_ecs_encryption" {
  description              = "EFS inbound access from ecs task sg"
  protocol                 = "tcp"
  from_port                = 2999
  to_port                  = 2999
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = aws_security_group.ecs.id
  type                     = "ingress"
}


resource "aws_security_group_rule" "ingress_load_balancer_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  to_port           = 80
  cidr_blocks = [
  "0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_load_balancer_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  to_port           = 443
  cidr_blocks = [
  "0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_ecs_task_elb" {
  from_port                = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs.id
  to_port                  = 8080
  source_security_group_id = aws_security_group.load_balancer.id
  type                     = "ingress"
}

resource "aws_security_group_rule" "egress_load_balancer" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
  "0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "egress_ecs_task" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  cidr_blocks = [
  "0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}