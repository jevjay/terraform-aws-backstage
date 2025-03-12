resource "aws_lb" "backstage" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backstage_alb.id]
  subnets            = length(var.existing_public_subnet_ids) > 0 ? var.existing_public_subnet_ids : module.vpc[0].public_subnets

  enable_deletion_protection = false

  tags = local.tags
}

resource "aws_lb_target_group" "backstage" {
  name        = "${local.name_prefix}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  target_type = "ip"
  
  health_check {
    enabled             = true
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    matcher             = "200-399"
  }

  tags = local.tags
}

resource "aws_lb_listener" "backstage_http" {
  load_balancer_arn = aws_lb.backstage.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backstage.arn
  }

  tags = local.tags
}
