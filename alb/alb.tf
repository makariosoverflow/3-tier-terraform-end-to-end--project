resource "aws_security_group" "alb_sg" {
  name        = "apci_alb_sg"
  description = "Allow SSH, HTTP and HTTPS Traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_http_https"
  }
}
#CREATING INBOUND SECURITY GROUP FOR APPLICATION LOAD BALANCER_____________________________________________________________________________________________________________________
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

#CREATING OUTBOUND SECURITY GROUP FOR APPLICATION LOAD BALANCER_____________________________________________________________________________________________________________________
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#CREATING TARGET GROUP FOR APPLICATION LOAD BALANCER_____________________________________________________________________________________________________________________
resource "aws_lb_target_group" "target_group" {
  name        = "apci-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

    health_check {
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200,301,302"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold =2
  }
}


resource "aws_lb" "apci_alb" {
  name               = "apci-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.frontend-subnet-az1a, var.frontend-subnet-az1b]

  enable_deletion_protection = false

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-alb"
  })
}

# CREATING A LISTENER ON PORT 80 WITH REDIRECT ACTION___________________________________________________________________________________________________________________

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.apci_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# create a listener on port 443 with SSL Certificate and default action___________________________________________________________________________________________________

resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.apci_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}