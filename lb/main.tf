resource "aws_lb" "default" {
  name            = "example-lb"
  subnets         = var.public_subnets_ids
  security_groups = [var.security_group_id]

  tags = {
    Name = "${var.name}-lb"
  }
}

resource "aws_lb_target_group" "hello_world" {
  name        = "workshop-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  tags = {
    Name = "${var.name}-tg"
  }
}

resource "aws_lb_listener" "hello_world" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_world.id
    type             = "forward"
  }

  tags = {
    Name = "${var.name}-lb-listener"
  }
}

output "target_group_arn" {
  value = aws_lb_target_group.hello_world.arn
}

output "lb_id" {
  value = aws_lb.default.id
}

output "load_balancer_ip" {
  value = aws_lb.default.dns_name
}

output "lb_listener" {
  value = aws_lb_listener.hello_world.id
}