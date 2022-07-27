
resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ecs_task_execution_role
  task_role_arn            = var.ecs_task_role

  container_definitions = <<DEFINITION
[
  {
    "image": "813017864691.dkr.ecr.us-west-2.amazonaws.com/workshop-ecr:latest",
    "cpu": 256,
    "memory": 512,
    "name": "hello-world-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}


resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.hello_world.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.hello_world_task.id]
    subnets         = var.private_subnets_ids
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "hello-world-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.hello_world]
}