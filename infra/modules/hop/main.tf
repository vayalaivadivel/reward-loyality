resource "aws_lb" "hop" {

  name = "reward-loyalty-hop-alb-${var.env}"

  internal = false

  load_balancer_type = "application"

  security_groups = [aws_security_group.hop_alb.id]

  subnets = var.public_subnets
}

resource "aws_security_group" "hop_alb" {

  name = "reward-loyalty-hop-alb-sg-${var.env}"

  vpc_id = var.vpc_id

  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "hop" {

  name = "reward-hop-tg-${var.env}"

  port = 8080

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {

    path = "/"

    protocol = "HTTP"
  }
}


resource "aws_lb_listener" "hop" {

  load_balancer_arn = aws_lb.hop.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.hop.arn
  }
}