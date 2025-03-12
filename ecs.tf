resource "aws_ecs_cluster" "backstage" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "backstage" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 30
  tags              = local.tags
}

resource "aws_ecs_task_definition" "backstage" {
  family                   = "${local.name_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "backstage"
    image     = var.container_image
    essential = true
    
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]
    
    environment = [
      for k, v in var.environment_variables : {
        name  = k
        value = v
      }
    ]
    
    secrets = var.create_database ? [
      {
        name      = "POSTGRESQL_PASSWORD"
        valueFrom = aws_secretsmanager_secret.database_password[0].arn
      }
    ] : []
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.backstage.name
        "awslogs-region"        = data.aws_region.current.name
        "awslogs-stream-prefix" = "backstage"
      }
    }
  }])

  tags = local.tags
}

resource "aws_ecs_service" "backstage" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.backstage.id
  task_definition = aws_ecs_task_definition.backstage.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count
  
  network_configuration {
    subnets         = length(var.existing_private_subnet_ids) > 0 ? var.existing_private_subnet_ids : module.vpc[0].private_subnets
    security_groups = [aws_security_group.backstage_ecs.id]
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.backstage.arn
    container_name   = "backstage"
    container_port   = var.container_port
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  
  tags = local.tags

  depends_on = [aws_lb_listener.backstage_http]
}

data "aws_region" "current" {}
