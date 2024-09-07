variable "ecr_repository_name" {
  type        = string
  description = "The name of the ECR repository"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "aws_region" {
  default     = "ap-south-1"
  description = "The AWS region"
}

variable "subnet_ids" {
  description = "The list of subnet IDs to associate with the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "The list of security group IDs to associate with the ECS service"
  type        = list(string)
}
