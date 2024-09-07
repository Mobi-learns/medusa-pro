# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# Add policies to the ECS Task Role if needed
# Example:
# resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = "arn:aws:iam::aws:policy/YourRequiredPolicy"
# }

# Define ECS Task Definition
resource "aws_ecs_task_definition" "medusa_task" {
  family                = "medusa-task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn    = aws_iam_role.ecs_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name      = "medusa-container"
    image     = "590183752334.dkr.ecr.ap-south-1.amazonaws.com/medusa-store:latest"
    essential = true
    memory    = 512
    cpu       = 256
  }])
  memory                = "512"
  cpu                   = "256"
}

# Define ECS Cluster
resource "aws_ecs_cluster" "medusa_cluster" {
  name = var.ecs_cluster_name
}

# Define ECS Service
resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = true
  }
}
