output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.medusa_cluster.name
}
