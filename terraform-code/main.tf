provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

resource "aws_ecr_repository" "atc_repo" {
  name = "atc_repo" # Naming my repository
}

resource "aws_ecs_cluster" "atc_cluster" {
  name = "atc_cluster"
}

resource "aws_ecs_task_definition" "atc_task" {
  family                   = "atc-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "atc-task",
      "image": "${aws_ecr_repository.atc_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 81,
          "hostPort": 81
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
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
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "us-east-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = "us-east-1c"
}


resource "aws_ecs_service" "atc_service" {
  name            = "atc_service"
  cluster         = "${aws_ecs_cluster.atc_cluster.id}"
  task_definition = "${aws_ecs_task_definition.atc_task.arn}"
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true
  }
}


