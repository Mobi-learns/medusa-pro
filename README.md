Medusa E-Commerce Platform Deployment on AWS ECS with Terraform and CI/CD Pipeline

Project Overview
This project demonstrates the deployment of a Medusa e-commerce platform backend on AWS using Elastic Container Service (ECS) with Fargate. The infrastructure is provisioned using Terraform, and the deployment is automated via a GitHub Actions CI/CD pipeline.
Project Architecture:
Platform: Medusa, a headless open-source e-commerce platform.
Cloud Provider: AWS (Amazon Web Services).
Container Orchestration: AWS ECS (Elastic Container Service) on Fargate (serverless).
CI/CD Pipeline: GitHub Actions automating continuous integration and deployment.
Infrastructure as Code (IaC): Terraform automating the creation of ECS clusters, tasks, services, and networking.
Container Registry: AWS ECR (Elastic Container Registry) hosting Docker images for the Medusa application.
In this project, I demonstrate my expertise in deploying the Medusa headless e-commerce platform using AWS ECS (Elastic Container Service) and Fargate for serverless hosting. The infrastructure is provisioned with Terraform, and GitHub Actions is used to automate the CI/CD pipeline, building and deploying the Dockerized Medusa backend. This project shows proficiency in:
DevOps principles, including infrastructure automation.
Managing containerized deployments with Docker.
Using AWS services like ECS, ECR, and IAM roles for a scalable infrastructure.
Implementing GitHub Actions for Continuous Deployment (CD).
Step 1: Clone Medusa Backend Source Code
The Medusa platform's backend code is open-source and can be downloaded from its GitHub repository.
Clone the Medusa Backend Repository:
The first step is to clone the source code onto your local system or cloud server (e.g., an AWS EC2 instance):
git clone https://github.com/medusajs/medusa.git my-medusa-store
cd my-medusa-store

Install Dependencies:
Ensure you have Node.js installed (the version required is 18.20.4).
Navigate to the project directory and install dependencies:
npm install

Set Up Medusa Environment:
Create an .env file in the root directory to configure the Medusa backend.
Run Medusa Backend Locally:
To verify everything is set up correctly, run the Medusa backend locally:
npm run start

Step 2: Containerize the Medusa Backend with Docker
In this step, we containerize the Medusa backend to make it portable and deployable on AWS ECS.
Create a Dockerfile:
In the root of your project, create a Dockerfile to containerize the backend:
# Use Node.js 18 as the base image
FROM node:18

# Set the working directory
WORKDIR /app

# Copy the package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the entire app into the container
COPY . .

# Set environment variables (ensure you have an appropriate .env file)
ENV NODE_ENV=production

# Expose port 9000 for the Medusa backend
EXPOSE 9000

# Start the Medusa backend
CMD ["npm", "run", "start"]


Build Docker Image:
Build the Docker image locally:
bash
Copy code
docker build -t medusa-store .


Step 3: Provision AWS Infrastructure with Terraform
Here we will use Terraform to manage all AWS resources, including ECR (Elastic Container Registry) for storing the Docker image, ECS cluster, ECS task definitions, and Fargate service.
Set Up Directory Structure

mkdir -p terraform
touch terraform/main.tf terraform/variables.tf terraform/outputs.tf

Main Terraform Configuration (main.tf)
hcl
Copy code
provider "aws" {
  region = "ap-south-1"
}

# Create ECR Repository
resource "aws_ecr_repository" "medusa_repo" {
  name = "medusa-repo"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

# Define ECS Task Definition
resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "medusa-task"
  container_definitions     = jsonencode([{
    name      = "medusa-container"
    image     = "${aws_ecr_repository.medusa_repo.repository_url}:latest"
    essential = true
    memory    = 512
    cpu       = 256
    portMappings = [{
      containerPort = 9000
      hostPort      = 9000
      protocol      = "tcp"
    }]
  }])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                  = "512"
  cpu                     = "256"
  execution_role_arn      = aws_iam_role.ecs_execution_role.arn
}

# Create ECS Service
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

# IAM Roles for ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

Variables and Outputs (variables.tf, outputs.tf)
In variables.tf, define any variables like subnet IDs and security groups:
hcl
Copy code
variable "subnet_ids" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

In outputs.tf, output important information:
hcl
Copy code
output "ecs_cluster_name" {
  value = aws_ecs_cluster.medusa_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.medusa_service.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.medusa_repo.repository_url
}

Step 3.3: Apply Terraform Configuration
Initialize and apply the Terraform configuration:
bash
Copy code
terraform init
terraform apply


Step 4: Push Docker Image to ECR
Once the ECR repository is created, use the AWS CLI to push your Docker image to ECR.
Log in to ECR:
bash
Copy code
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 590183752334.dkr.ecr.ap-south-1.amazonaws.com


Tag and Push the Docker Image:
bash
Copy code
docker tag medusa-store:latest 590183752334.dkr.ecr.ap-south-1.amazonaws.com/medusa-repo:latest
docker push 590183752334.dkr.ecr.ap-south-1.amazonaws.com/medusa-repo:latest


Step 5: Set Up CI/CD Pipeline with GitHub Actions
Automate the Docker image building and deployment to ECS using GitHub Actions.
Step 5.1: Create Workflow File
Create a GitHub Actions workflow .github/workflows/cd-pipeline.yml:
yaml
Copy code
name: CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18.20.4'

    - name: Install dependencies
      run: npm install

    - name: Build Docker image
      run: docker build -t medusa-store .

    - name: Login to Amazon ECR
      run: |
        aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

    - name: Tag and push Docker image
      run: |
        docker tag medusa-store:latest ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/medusa-repo:latest
        docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.${{ secrets.AWS_REGION }}.amazonaws.com/medusa-repo:latest

    - name: Update ECS Service
      run: |
        aws ecs update-service --cluster $(terraform output -raw ecs_cluster_name) --service $(terraform output -raw ecs_service_name) --force-new-deployment
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: ${{ secrets.AWS_REGION }}

Step 5.2: Add Secrets to GitHub
In your repository, go to Settings → Secrets and add the following secrets:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
Step 6: Push Code and Trigger Pipeline
Push code to GitHub:
bash
Copy code
git add .
git commit -m "Deploy Medusa on ECS"
git push origin main –force


This will trigger the GitHub Actions workflow, building the Docker image, pushing it to ECR, and updating the ECS service to deploy the new version.

Conclusion
In this project, we:
Provisioned AWS Infrastructure using Terraform, including ECS clusters, task definitions, services, and an ECR repository.
Containerized the Medusa e-commerce backend with Docker.
Automated CI/CD using GitHub Actions to deploy updates to the AWS ECS service.
Github Repo: https://github.com/Mobi-learns/medusa-pro






