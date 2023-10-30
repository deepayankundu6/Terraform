provider "aws" {
  region     = "ap-south-1"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ECS-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags = {
    Name        = "ecs-iam-role"
    Environment = "dev"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

variable "SG_Name"{
  type = string
  default = "My_Jenkins_SG"
}

resource "aws_vpc" "my_VPC" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "subnet-1" {
  vpc_id                  = aws_vpc.my_VPC.id
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = "true"
}

resource "aws_security_group" "allow_jenkins" {
  name        = var.SG_Name
  description = "Allow Jenkins inbound traffic"
  vpc_id      = aws_vpc.my_VPC.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 0
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_internet_gateway" "ig-1" {
  vpc_id = aws_vpc.my_VPC.id
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "my-jenkins-lg"
}

resource "aws_ecs_cluster" "my-ecs-cluster" {
  name = "my-jenkins-cluster"
}

resource "aws_ecs_task_definition" "my-ecs-jenkins-task" {
  family = "my-task"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions = <<DEFINITION
  [
    {
      "name": "Jenkins-container",
      "image": "jenkins/jenkins:lts",
      "entryPoint": [],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "ap-south-1",
          "awslogs-stream-prefix": "Deep"
        }
      },
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "cpu": 1024,
      "memory": 2048,
      "networkMode": "awsvpc"
    }
  ]
  DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "2048"
  cpu                      = "1024"
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "jenkins-ecs-service"
  cluster              = aws_ecs_cluster.my-ecs-cluster.id
  task_definition      = aws_ecs_task_definition.my-ecs-jenkins-task.family
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = ["${aws_subnet.subnet-1.id}"]
    assign_public_ip = true
    security_groups = [
      aws_security_group.allow_jenkins.id
    ]
  }
}
