
# Medusa E-Commerce Platform Deployment on AWS ECS with Terraform and CI/CD Pipeline

This project demonstrates the deployment of the [Medusa](https://medusajs.com/) e-commerce platform backend on AWS using Elastic Container Service (ECS) with Fargate. The infrastructure is provisioned using Terraform, and the deployment is automated via a GitHub Actions CI/CD pipeline.

## **Project Overview**

This project illustrates:
- **Cloud Provider**: AWS (Amazon Web Services)
- **Container Orchestration**: AWS ECS (Elastic Container Service) on Fargate (serverless)
- **CI/CD Pipeline**: Automated using GitHub Actions
- **Infrastructure as Code (IaC)**: Provisioned using Terraform
- **Container Registry**: AWS ECR (Elastic Container Registry) hosting Docker images for the Medusa backend

## **Skills Demonstrated**

- **DevOps principles**: Infrastructure automation, CI/CD implementation.
- **Containerized Deployments**: Using Docker.
- **AWS Services**: ECS, ECR, IAM roles, scalable and serverless infrastructure.
- **GitHub Actions**: For automated continuous integration and deployment.

## **Project Architecture**

1. **Platform**: Medusa, a headless open-source e-commerce platform.
2. **Cloud Provider**: AWS (Amazon Web Services).
3. **Container Orchestration**: AWS ECS with Fargate (serverless).
4. **CI/CD Pipeline**: Automated with GitHub Actions.
5. **Infrastructure as Code (IaC)**: Terraform to automate ECS clusters, tasks, services, and networking.

## **Deployment Steps**

### Step 1: Clone Medusa Backend Source Code
Clone the Medusa backend code and install dependencies:

```bash
git clone https://github.com/medusajs/medusa.git my-medusa-store
cd my-medusa-store
npm install
```

### Step 2: Containerize the Medusa Backend with Docker
Create a Dockerfile to containerize the backend:

```Dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ENV NODE_ENV=production
EXPOSE 9000
CMD ["npm", "run", "start"]
```

Build the Docker image:

```bash
docker build -t medusa-store .
```

### Step 3: Provision AWS Infrastructure with Terraform
Set up Terraform configuration files to provision the ECS cluster, task definitions, and services:

- **Main Configuration**: `main.tf`
- **Variables**: `variables.tf`
- **Outputs**: `outputs.tf`

Initialize and apply the configuration:

```bash
terraform init
terraform apply
```

### Step 4: Push Docker Image to AWS ECR
Log in to ECR and push the Docker image:

```bash
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 590183752334.dkr.ecr.ap-south-1.amazonaws.com
docker tag medusa-store:latest 590183752334.dkr.ecr.ap-south-1.amazonaws.com/medusa-repo:latest
docker push 590183752334.dkr.ecr.ap-south-1.amazonaws.com/medusa-repo:latest
```

### Step 5: Set Up CI/CD Pipeline with GitHub Actions
Automate Docker image builds and ECS deployment using GitHub Actions. Create a workflow file `.github/workflows/cd-pipeline.yml`:

```yaml
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
```

### Step 6: Trigger CI/CD Pipeline
Push your code to GitHub:

```bash
git add .
git commit -m "Deploy Medusa on ECS"
git push origin main --force
```

This will trigger the GitHub Actions workflow to build and deploy the Medusa backend on AWS ECS.

## **Conclusion**

In this project, I demonstrated how to:
- Provision AWS infrastructure with Terraform (ECS cluster, task definitions, services, and ECR).
- Containerize the Medusa e-commerce platform using Docker.
- Set up a CI/CD pipeline with GitHub Actions to automate deployment to AWS ECS.

**GitHub Repository**: [Mobi-learns/medusa-pro](https://github.com/Mobi-learns/medusa-pro)
