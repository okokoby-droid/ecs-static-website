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

## Challenges and Troubleshooting

### GitHub OIDC Authentication

**Problem:** AWS rejected the GitHub Actions role assumption.

**Resolution:** Inspected GitHub OIDC token claims and updated the IAM role trust policy to match the actual repository subject.

### Docker Image Push to ECR

**Problem:** Docker returned a `403 Forbidden` error while processing an image manifest.

**Resolution:** Updated the Docker build command to disable provenance attestations. The subsequent CI/CD workflow completed successfully.

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
