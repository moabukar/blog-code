resource "aws_ecs_cluster" "backstage" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ecs_cluster_capacity_providers" "backstage" {
  cluster_name = aws_ecs_cluster.backstage.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.environment == "production" ? "FARGATE" : "FARGATE_SPOT"
  }
}

resource "aws_cloudwatch_log_group" "backstage" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.environment == "production" ? 90 : 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ecs_task_definition" "backstage" {
  family                   = var.project_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "backstage"
      image = "${aws_ecr_repository.backstage.repository_url}:${var.image_tag}"

      essential = true

      portMappings = [
        {
          containerPort = var.backstage_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "APP_CONFIG_app_baseUrl"
          value = "https://${var.domain_name}"
        },
        {
          name  = "APP_CONFIG_backend_baseUrl"
          value = "https://${var.domain_name}"
        },
        {
          name  = "APP_CONFIG_backend_cors_origin"
          value = "https://${var.domain_name}"
        }
      ]

      secrets = [
        {
          name      = "POSTGRES_HOST"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:host::"
        },
        {
          name      = "POSTGRES_PORT"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:port::"
        },
        {
          name      = "POSTGRES_USER"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:username::"
        },
        {
          name      = "POSTGRES_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:password::"
        },
        {
          name      = "COGNITO_CLIENT_ID"
          valueFrom = "${aws_secretsmanager_secret.cognito_client_secret.arn}:client_id::"
        },
        {
          name      = "COGNITO_CLIENT_SECRET"
          valueFrom = "${aws_secretsmanager_secret.cognito_client_secret.arn}:client_secret::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backstage.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backstage"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.backstage_port}/healthcheck || exit 1"]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_ecs_service" "backstage" {
  name                               = var.project_name
  cluster                            = aws_ecs_cluster.backstage.id
  task_definition                    = aws_ecs_task_definition.backstage.arn
  desired_count                      = var.ecs_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  health_check_grace_period_seconds  = 120

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backstage.arn
    container_name   = "backstage"
    container_port   = var.backstage_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Auto-scaling
resource "aws_appautoscaling_target" "backstage" {
  max_capacity       = var.ecs_max_count
  min_capacity       = var.ecs_min_count
  resource_id        = "service/${aws_ecs_cluster.backstage.name}/${aws_ecs_service.backstage.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.project_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backstage.resource_id
  scalable_dimension = aws_appautoscaling_target.backstage.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backstage.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "memory" {
  name               = "${var.project_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backstage.resource_id
  scalable_dimension = aws_appautoscaling_target.backstage.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backstage.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 80.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
