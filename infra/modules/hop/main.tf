############################################################
# CLOUDWATCH LOG GROUP
############################################################

resource "aws_cloudwatch_log_group" "hop" {

  name = "/ecs/reward-loyalty-hop-${var.env}"

  retention_in_days = 7
}

############################################################
# ECS CLUSTER
############################################################

resource "aws_ecs_cluster" "hop" {

  name = "reward-loyalty-ecs-${var.env}"
}

############################################################
# ECS SECURITY GROUP
############################################################

resource "aws_security_group" "hop_ecs" {

  name = "reward-loyalty-hop-ecs-sg-${var.env}"

  vpc_id = var.vpc_id

  ingress {

    from_port = 8080

    to_port = 8080

    protocol = "tcp"

    security_groups = [
      aws_security_group.hop_alb.id
    ]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################################
# ALB SECURITY GROUP
############################################################

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

############################################################
# APPLICATION LOAD BALANCER
############################################################

resource "aws_lb" "hop" {

  name = "reward-loyalty-hop-alb-${var.env}"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.hop_alb.id
  ]

  subnets = var.public_subnets
}

############################################################
# TARGET GROUP
############################################################

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

############################################################
# LISTENER
############################################################

resource "aws_lb_listener" "hop" {

  load_balancer_arn = aws_lb.hop.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.hop.arn
  }
}

############################################################
# ECS TASK DEFINITION
############################################################

resource "aws_ecs_task_definition" "hop" {

  family = "reward-loyalty-hop-${var.env}"

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]

  cpu = "512"

  memory = "1024"

  execution_role_arn = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([

    {

      name = "reward-loyalty-hop"

      image = "${var.ecr_repository_url}:reward-loyalty-${var.env}"

      essential = true

      portMappings = [

        {

          containerPort = 8080

          hostPort = 8080

          protocol = "tcp"
        }
      ]

      ####################################################
      # ECS HEALTH CHECK
      ####################################################

      healthCheck = {

        command = [

          "CMD-SHELL",

          "wget -q --spider http://localhost:8080/hop/status/ || exit 1"
        ]

        interval = 30

        timeout = 5

        retries = 3

        startPeriod = 120
      }

      ####################################################
      # CLOUDWATCH LOGS
      ####################################################

      logConfiguration = {

        logDriver = "awslogs"

        options = {

          awslogs-group = aws_cloudwatch_log_group.hop.name

          awslogs-region = var.aws_region

          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

############################################################
# ECS SERVICE
############################################################

resource "aws_ecs_service" "hop" {

  name = "reward-loyalty-hop-service-${var.env}"

  cluster = aws_ecs_cluster.hop.id

  task_definition = aws_ecs_task_definition.hop.arn

  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {

    subnets = var.private_subnets

    security_groups = [
      aws_security_group.hop_ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {

    target_group_arn = aws_lb_target_group.hop.arn

    container_name = "reward-loyalty-hop"

    container_port = 8080
  }

  depends_on = [
    aws_lb_listener.hop
  ]
}