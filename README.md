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
                       |
                    Route 53
                       |
                       |
                     ALB
                       |
              -----------------
              |               |
          App EC2          App SG
              |
              |
        TCP 3306 allowed
              |
              |
          RDS MySQL
              |
            DB SG
```

---

## Project Structure

```
.
├── live
    ├── create.sh
    ├── destroy.sh 
│   ├── platform
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── backend.tf
│   │
│   └── data
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── backend.tf
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
* EC2 instances
* Security groups
* IAM roles

### Database Layer

* Amazon RDS MySQL
* Private database subnet deployment
* Database security group
* Restricted access from application tier only

### Monitoring

* CloudWatch Logs
* CloudWatch Alarms
* SNS notifications

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

Initialize Terraform:

```bash
terraform init
```

Validate configuration:

```bash
terraform validate
```

Create execution plan:

```bash
terraform plan
```

Deploy infrastructure:

```bash
terraform apply
```

Destroy infrastructure:

Destroy order:

1. Data stack

```bash
cd live/data
terraform destroy
```

2. Platform stack

```bash
cd ../platform
terraform destroy
```

---

## Security Design

* Database is not publicly accessible
* Database access is restricted to application security group
* Infrastructure follows least privilege principles
* Terraform state is stored remotely
* Sensitive variables are excluded from Git

---

## Future Enhancements

Planned improvements:

* Multiple environments (dev/qa/prod)
* GitLab CI/CD pipeline
* Terraform security scanning
* Automated infrastructure validation
* Kubernetes/EKS deployment
* GitOps workflow using Argo CD

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
