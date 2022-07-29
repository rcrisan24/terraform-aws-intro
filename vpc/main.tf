data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block = "10.32.0.0/16"

  tags = {
    Name = "${var.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.default.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.default.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.default.id

  tags = {
    Name = "${var.name}-private-subnet"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}


resource "aws_security_group" "lb" {
  name        = "${var.name}-alb-sg"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg-lb"
  }
}


resource "aws_security_group" "hello_world_task" {
  name        = "${var.name}-task-sg"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-vpc"
  }
}

output "vpc_arn" {
  value = aws_vpc.default.arn
}

output "vpc_id" {
  value = aws_vpc.default.id
}

output "public_subnets_ids" {
  value =  aws_subnet.public.*.id
}

output "private_subnets_ids" {
  value = aws_subnet.private.*.id
}

output "lb_security_group" {
  value = aws_security_group.lb.id
}

output "ecs_task_sg_id" {
  value = aws_security_group.hello_world_task.id
}