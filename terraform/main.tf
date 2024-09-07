provider "aws" {
  region = var.aws_region
}

# Call the ECR module
module "ecr" {
  source = "./ecr"
   ecr_repository_name = var.ecr_repository_name  
}

# Call the ECS module and pass ECR repository URL to it
module "ecs" {
  source            = "./ecs"
  ecs_cluster_name  = var.ecs_cluster_name
  subnet_ids        = var.subnet_ids
  security_groups   = var.security_groups
  ecr_repository_url = module.ecr.repository_url # Pass the ECR repo URL to the ECS module
}
