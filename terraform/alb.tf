# Application Load Balancer Configuration

################################################################################
# Application Load Balancer
################################################################################

resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
    Type = "load-balancer"
  })
}

# ALB Target Group
resource "aws_lb_target_group" "backend" {
  name        = "${local.name_prefix}-backend-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 60            # Increased from 30 to 45 seconds
    matcher             = "200"
    path                = "/health"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = 20            # Increased from 5 to 10 seconds
    unhealthy_threshold = 2             # Increased from 3 to 5
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-tg"
    Type = "target-group"
  })
}

# ALB Listener for port 80 - redirects to port 8080
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "8080"
      protocol    = "HTTP"
      status_code = "HTTP_301"
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-http-redirect-listener"
    Type = "lb-listener"
  })
}

# ALB Listener for port 8080 - forwards to backend service
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.main.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-listener"
    Type = "lb-listener"
  })
}