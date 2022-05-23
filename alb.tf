# Provision an Application Load Balancer in the Alpha region
resource "aws_lb" "jenkins_alb" {
  provider           = aws.region-alpha
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_subnet.subnet_1_alpha.id, aws_subnet.subnet_2_alpha.id]
  tags = {
    Name = "jenkins_alb"
  }
}

# Create a target group and configure health check settings
resource "aws_lb_target_group" "jenkins_alb_tg" {
  provider    = aws.region-alpha
  name        = "jenkins-alb-tg"
  port        = var.web_port
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_alpha.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = var.web_port
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    Name = "jenkins_alb_tg"
  }
}

# Configure listener settings to support default redirect action to HTTPS port
resource "aws_lb_listener" "jenkins_http_listener" {
  provider          = aws.region-alpha
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = var.web_port
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create HTTPS listener
resource "aws_lb_listener" "jenkins_https_listener" {
  provider          = aws.region-alpha
  load_balancer_arn = aws_lb.jenkins_alb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.jenkins_certificate.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_alb_tg.arn
  }
}

# Attached the target group to the Jenkins Master Node
resource "aws_lb_target_group_attachment" "jenkins_master_attach_tg" {
  provider         = aws.region-alpha
  target_group_arn = aws_lb_target_group.jenkins_alb_tg.arn
  target_id        = aws_instance.jenkins_master_instance.id
  port             = var.web_port
}



