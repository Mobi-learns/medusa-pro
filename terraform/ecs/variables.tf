variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}
