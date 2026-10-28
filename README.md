# AWS ECS Fargate Static Website — Automated CI/CD Deployment

## Project Overview

This project demonstrates how to containerize an Apache static website and automatically deploy it to Amazon ECS Fargate using GitHub Actions.

AWS infrastructure is provisioned and managed using Terraform, while GitHub Actions automates Docker image building, image publishing to Amazon Elastic Container Registry (ECR), and deployment to Amazon ECS.

**Project repository:** https://github.com/okokoby-droid/ecs-static-website

## Architecture

```text
Developer
    |
    v
GitHub Repository (main branch)
    |
    v
GitHub Actions CI/CD
    |
    +--> AWS IAM OIDC Authentication
    |
    v
Docker Build (Apache HTTP Server)
    |
    v
Amazon Elastic Container Registry (ECR)
    |
    v
Amazon ECS Fargate
    |
    v
Public Subnet + Security Group
    |
    v
Static Website (HTTP Port 80)
```

## Technologies Used

| Technology | Purpose |
|---|---|
| Git and GitHub | Source code and version control |
| GitHub Actions | Automated CI/CD pipeline |
| Docker | Containerizing the Apache website |
| Apache HTTP Server | Serving static website content |
| Amazon ECR | Storing Docker container images |
| Amazon ECS Fargate | Running containers without managing EC2 servers |
| Terraform | Infrastructure as Code for AWS resources |
| AWS IAM and OIDC | Secure GitHub Actions authentication |
| Amazon VPC | Isolated AWS networking |
| Security Groups | Controlling inbound and outbound traffic |
| Amazon CloudWatch | ECS container logging |

## Infrastructure Provisioning with Terraform

Terraform is used to provision and manage AWS infrastructure, including:

- Virtual Private Cloud (VPC)
- Public subnet
- Security group
- Amazon ECR repository
- ECS cluster
- ECS task definition
- ECS service
- IAM task execution role
- CloudWatch log group

The infrastructure configuration is located in the `terraform/` directory.

## Docker Containerization

The website is served using Apache HTTP Server inside a Docker container.

The Dockerfile uses the official Apache image and copies the static website into Apache's document root.

```dockerfile
FROM httpd:2.4

COPY index.html /usr/local/apache2/htdocs/index.html

EXPOSE 80
```

## CI/CD Pipeline

The GitHub Actions workflow is located at:

`.github/workflows/deploy.yml`

The pipeline runs automatically when changes are pushed to the `main` branch and can also be started manually.

### Deployment Process

1. Check out the GitHub repository.
2. Authenticate to AWS using GitHub OIDC and an IAM role.
3. Log in to Amazon ECR.
4. Build the Docker image.
5. Tag the image using the Git commit SHA.
6. Push the image to Amazon ECR.
7. Retrieve the existing ECS task definition.
8. Register a new task definition revision using the updated image.
9. Update the ECS service.
10. Wait for the ECS service to stabilize.

The Docker build uses `--provenance=false` to avoid an image-manifest compatibility or permissions issue encountered during deployment.

## Security Practices

- GitHub Actions authenticates using OIDC rather than long-lived AWS access keys.
- The IAM role has permissions scoped to the deployment workflow.
- ECR stores the container images.
- Terraform state files and sensitive local configuration are excluded from Git version control.
- Security groups control network access to the application.

## Deployment Verification

The project was successfully deployed to Amazon ECS Fargate in the AWS Frankfurt region (`eu-central-1`).

A successful GitHub Actions deployment was recorded in workflow run #7.

The deployed Apache website was verified through the ECS task's public IP address.

The public IP is temporary and may change if the ECS task is replaced.
### CI/CD Workflow Improvement — October 28, 2026

Successfully improved the GitHub Actions deployment workflow and added project documentation.

- Created and committed the project README.
- Configured `paths-ignore` to prevent automatic deployments for Markdown-only changes.
- Successfully executed GitHub Actions deployment run #8.
- Confirmed successful completion of the automated ECS deployment workflow.

**Commit:** `fb9339a`

**Result:** The updated CI/CD workflow completed successfully in 2 minutes and 40 seconds.
## Challenges and Troubleshooting

### GitHub OIDC Authentication

**Problem:** AWS rejected the GitHub Actions role assumption.

**Resolution:** Inspected GitHub OIDC token claims and updated the IAM role trust policy to match the actual repository subject.

### Docker Image Push to ECR

**Problem:** Docker returned a `403 Forbidden` error while processing an image manifest.

**Resolution:** Updated the Docker build command to disable provenance attestations. The subsequent CI/CD workflow completed successfully.
### Terraform Network Expansion — October 28, 2026

Successfully expanded the existing AWS VPC network to support an Application Load Balancer.

**Implementation steps:**

1. Created a second public subnet (`10.0.2.0/24`) in Availability Zone `eu-central-1b`.
2. Associated the second subnet with the existing public route table and Internet Gateway.
3. Added a Terraform lifecycle rule to prevent Terraform from reverting ECS task definition revisions deployed by GitHub Actions.
4. Validated the infrastructure configuration using `terraform plan`.
5. Applied the Terraform changes successfully.

**AWS resources created:**

- Public subnet: `subnet-04cfc2a83e87e67dc`
- Route table association: `rtbassoc-0b53df93969c7582d`

**Terraform result:** `2 added, 0 changed, 0 destroyed`.

**Outcome:** Two public subnets are now available in different Availability Zones, preparing the VPC for an internet-facing Application Load Balancer without modifying the existing ECS service.
### Workflow YAML Validation

**Problem:** GitHub Actions rejected the workflow because of incorrect YAML indentation.

**Resolution:** Corrected the job and step indentation and reran the workflow.

## Future Improvements

- Add an Application Load Balancer for a stable website endpoint.
- Configure HTTPS using AWS Certificate Manager.
- Add a custom domain.
- Configure CloudWatch alarms and service monitoring.
- Remove temporary OIDC diagnostic logging from the workflow.
- Add automated testing and deployment safeguards.

## Project Outcome

Successfully implemented an automated container deployment workflow using GitHub Actions, Docker, Amazon ECR, Amazon ECS Fargate, Terraform and AWS IAM OIDC.

The project demonstrates practical skills in cloud infrastructure provisioning, containerization, infrastructure automation, CI/CD deployment and troubleshooting.

## Application Load Balancer Integration — October 28, 2026

### Objective
Expose the containerized Apache website through an AWS Application Load Balancer (ALB), with automatic health checks and traffic forwarding to ECS Fargate tasks.

### Infrastructure Provisioned with Terraform
- VPC: 10.0.0.0/16
- Public subnet 1: 10.0.1.0/24 (eu-central-1a)
- Public subnet 2: 10.0.2.0/24 (eu-central-1b)
- Internet Gateway and public route table
- Application Load Balancer: ecs-website-alb
- ALB security group allowing inbound HTTP on port 80
- HTTP listener forwarding traffic to ecs-website-tg
- Target group configured for IP targets and HTTP health checks
- ECS Fargate service integrated with the ALB target group

### Terraform Changes
Updated service.tf to include a load_balancer block referencing the ALB target group, Apache container name "website", and container port 80.

Added the ALB listener as an ECS service dependency.

Preserved lifecycle.ignore_changes for task_definition so GitHub Actions remains responsible for application deployments.

### Deployment Verification
Terraform apply:
- 0 resources added
- 1 resource changed
- 0 resources destroyed

Target group health:
- ECS task IP: 10.0.1.198
- Port: 80
- Status: healthy

HTTP test:
- ALB returned HTTP/1.1 200 OK
- Server: Apache/2.4.69 (Unix)

Website:
http://ecs-website-alb-1794379186.eu-central-1.elb.amazonaws.com

### IAM Troubleshooting
During deployment, missing IAM permissions prevented Terraform from reading or modifying some ALB resources.

Resolved these issues by updating appropriate IAM policies, including permissions for load balancer attributes, listener attributes, and target health checks.

Existing Terraform resources were untainted after confirming their successful creation in AWS, preventing unnecessary replacement.

### Outcome
Successfully deployed an Apache static website on Amazon ECS Fargate using Docker, Amazon ECR, Terraform, GitHub Actions CI/CD, and an AWS Application Load Balancer.

The ALB successfully routes HTTP requests to a healthy ECS Fargate task.
