
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
    "image": "716588360133.dkr.ecr.eu-west-2.amazonaws.com/workshop-ecr:latest",
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

tags = {
    Name = "${var.name}-task-definition"
  }

}


resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.hello_world.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [var.security_group_id]
    subnets         = var.public_subnets_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "hello-world-app"
    container_port   = 8080
  }

  depends_on = [var.lb_listener]

  tags = {
    Name = "${var.name}-task"
  }
}