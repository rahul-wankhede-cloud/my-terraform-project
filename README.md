# AWS 3-Tier Application Infrastructure with Terraform

## Overview

This project provisions a production-style 3-tier AWS application infrastructure using Terraform.

The infrastructure is designed using reusable Terraform modules and separated into independent stacks to improve maintainability, scalability, and state management.

The architecture separates:

* **Platform layer**: Networking, compute, load balancing, application security
* **Data layer**: Database resources and database security

Terraform state is managed remotely using an S3 backend with native state locking.

---

## Architecture

```
                      Internet
                         |
                     Route 53
                         |
                         |
               +-----------------+
               |       ALB       |
               |    (alb_sg)     |
               +-----------------+
                         |
                  Target Group
                         |
               +-----------------+
               |   EC2 Instance  |
               |    (app_sg)     |
               +-----------------+
                         |
                    TCP 3306
                         |
               +-----------------+
               |   Amazon RDS    |
               |    (db_sg)      |
               +-----------------+
```

---

## Environments

This project supports:

- dev
- qa
- prod

Each environment has isolated Terraform state:

dev:
s3://bucket/dev/platform/terraform.tfstate

qa:
s3://bucket/qa/platform/terraform.tfstate

prod:
s3://bucket/prod/platform/terraform.tfstate

---

## Project Structure

```
my-terraform-project/
│
├── README.md
├── create.sh
├── destroy.sh
├── .gitignore
│
├── live/
│   │
│   ├── dev/
│   │   │
│   │   ├── platform/
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   └── terraform.tfvars        (ignored)
│   │   │
│   │   └── data/
│   │       ├── backend.tf
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       ├── providers.tf
│   │       └── terraform.tfvars        (ignored)
│   │
│   │
│   ├── qa/
│   │   │
│   │   ├── platform/
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   └── terraform.tfvars        (ignored)
│   │   │
│   │   └── data/
│   │       ├── backend.tf
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       ├── providers.tf
│   │       └── terraform.tfvars        (ignored)
│   │
│   │
│   └── prod/
│       │
│       ├── platform/
│       │   ├── backend.tf
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   ├── providers.tf
│       │   └── terraform.tfvars        (ignored)
│       │
│       └── data/
│           ├── backend.tf
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           ├── providers.tf
│           └── terraform.tfvars        (ignored)
│
│
└── modules
    ├── networking
    ├── security-group
    ├── alb
    ├── ec2
    ├── database
    ├── iam-role
    ├── autoscaling-group
    ├── launch-template
    ├── cloudwatch
    ├── sns
    └── route53

```
| Tool           | Purpose                |
| -------------- | ---------------------- |
| Terraform      | Infrastructure as Code |
| GitHub Actions | CI/CD                  |
| AWS OIDC       | Secure authentication  |
| TFLint         | Terraform linting      |
| GitLeaks       | Secret detection       |
| pre-commit     | Local Git hooks        |

---

## Infrastructure Components

### Networking

* Custom VPC
* Public and private subnets
* Internet Gateway
* NAT Gateway
* Route tables

### Application Layer

* Application Load Balancer
* Auto Scaling Group (ASG)
* EC2 instances deployed through ASG
* Security groups
* IAM roles and instance permissions

The Auto Scaling Group provides:
  
 * Automatic instance replacement
 * Improved application availability
 * Dynamic scaling capability based on CloudWatch metrics

### Database Layer

* Amazon RDS MySQL
* Private database subnet deployment
* Database security group
* Restricted access from application tier only

Database connectivity is controlled using security group references:
```
Application Security Group
          |
          | 
          TCP 3306
          |
Database Security Group
```
### Monitoring And Alerting

* CloudWatch Logs
* CloudWatch Alarms
* SNS notifications

CloudWatch alarms are configured to monitor infrastructure metrics and trigger notifications through SNS when defined thresholds are exceeded.

### High Availability Design

The application tier is designed for resiliency using:

* Application Load Balancer
* Auto Scaling Group
* Health checks
* Multiple availability zones

If an application instance becomes unhealthy, the Auto Scaling Group can replace it automatically.

---

## Terraform Design

### Platform Stack

Responsible for:

* VPC
* Networking
* ALB
* EC2
* Application security group

Outputs:

* VPC ID
* Private subnet IDs
* Application security group ID

### Data Stack

Responsible for:

* Database security group
* RDS instance

Consumes platform outputs using:

```
terraform_remote_state
```

Example dependency:

```
Data Stack
    |
    |
    v

Platform Stack Outputs

(app_sg_id, subnet_ids, vpc_id)
```

---

## State Management

Terraform state is stored remotely:

```
AWS S3 Backend
        |
        |
 Native State Locking
```

Benefits:

* Shared state management
* Prevents concurrent state modification
* Supports CI/CD workflows

---

## Deployment

This project includes helper scripts to simplify infrastructure lifecycle management.

### Create Infrastructure

The `create.sh` script deploys the infrastructure in the correct order.

Run:

```bash
./create.sh
```

The deployment flow:

1. Deploy platform stack:

   * VPC
   * Networking
   * ALB
   * EC2
   * Application security group

2. Deploy data stack:

   * Database security group
   * RDS instance

The data stack consumes outputs from the platform stack using Terraform remote state.

---

### Destroy Infrastructure

The `destroy.sh` script removes resources in the correct dependency order.

Run:

```bash
./destroy.sh
```

Destroy order:

1. Data stack

   Removes:

   * RDS
   * Database security group rules
   * Database security group

2. Platform stack

   Removes:

   * EC2
   * ALB
   * Application security group
   * Networking resources
   * VPC

Destroying in this order prevents dependency issues caused by cross-stack references.

---

### Manual Terraform Commands

If required, Terraform can also be executed manually:

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```
----


## Security Design

* Database is not publicly accessible
* Database access is restricted to application security group
* Infrastructure follows least privilege principles
* Terraform state is stored remotely
* Sensitive variables are excluded from Git

---

## Current Features

- Modular Terraform architecture
- Separate platform and data stacks
- Remote Terraform state stored in S3 with locking
- Multiple environments:
  - dev
  - qa
  - prod
- Environment-specific Terraform state files
- Automated create and destroy scripts
- Application Load Balancer
- Auto Scaling Group
- CloudWatch monitoring and alarms
- SNS notifications
- RDS database deployment
- Security groups with least-privilege communication


## Future Enhancements

- GitLab CI/CD pipeline integration
- Terraform fmt/validate/plan automation
- Infrastructure security scanning using tools like Checkov/tfsec
- Secrets management using AWS Secrets Manager or SSM Parameter Store
- Kubernetes/EKS deployment
- GitOps workflow using Argo CD

---

## Technologies Used

* AWS
* Terraform
* Amazon VPC
* EC2
* ALB
* RDS MySQL
* IAM
* CloudWatch
* SNS
* Git

---
## Local Development Setup

### Prerequisites

Install the following tools:

- Git
- Terraform
- AWS CLI
- Python 3.x
- GitLeaks

### Install GitLeaks

winget install Gitleaks.Gitleaks

Verify the installation:

```bash
gitleaks version
```

### Install pre-commit

```bash
pip install pre-commit
```

Verify the installation:

```bash
pre-commit --version
```

### Install Git Hooks

From the root of the repository:

```bash
pre-commit install
```

You should see:

```text
pre-commit installed at .git/hooks/pre-commit
```

### Verify the Hooks

Run all configured hooks manually:

```bash
pre-commit run --all-files
```

From this point onward, GitLeaks will run automatically every time you execute:

```bash
git commit
```