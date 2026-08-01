#  Terraform AWS Ministack — Local Cloud Infrastructure Demo

![Terraform](https://img.shields.io/badge/Terraform-IaC-623CE4?logo=terraform)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker)
![AWS](https://img.shields.io/badge/AWS-Compatible-FF9900?logo=amazonaws)
![License](https://img.shields.io/badge/License-MIT-green)

A hands-on **Infrastructure as Code (IaC)** portfolio project that provisions an AWS-style cloud infrastructure stack completely locally using **Terraform** and **Ministack**, a free open-source AWS emulator.

The project recreates a small production-like environment containing:

- VPC networking
- Public and private subnets
- EC2 compute instances
- Application Load Balancer
- S3 storage
- RDS database

All resources are deployed locally — **without requiring an AWS account, credit card, or cloud billing.**

---

#  Why this project?

This project was created to practice real-world **Terraform and Cloud Engineering workflows** without depending on paid cloud resources.

The initial goal was to use **LocalStack**, one of the most popular AWS cloud emulators. However, many advanced AWS services such as EC2, RDS, and ALB moved behind LocalStack's paid Pro plan.

To keep the project fully free and open-source, I switched to **Ministack**.

Ministack provides:

- AWS-compatible APIs
- Terraform compatibility
- AWS CLI compatibility
- boto3 compatibility
- Local containers simulating services such as EC2 and RDS

This project became a practical exercise in:

- Terraform module design
- AWS provider configuration
- Remote state management
- Debugging Infrastructure as Code errors
- Designing cloud architectures locally

---

#  Architecture Overview

The infrastructure follows a simplified AWS multi-tier architecture:

```
                    Internet
                       |
                       |
              Application Load Balancer
                       |
              -------------------
              |                 |
            EC2 #1            EC2 #2
              |
              |
        Private Application Tier
              |
              |
             RDS Database


        S3 Bucket
        Terraform Remote State
```

---

# Infrastructure Components

The infrastructure is organized into reusable Terraform modules:

| Module | Description |
|--------|-------------|
| `vpc` | Creates VPC, public/private subnets, networking components |
| `s3` | Creates S3 storage buckets |
| `ec2` | Creates security groups and EC2 instances |
| `alb` | Creates Application Load Balancer |
| `rds` | Creates database infrastructure inside private subnet |

---

# oject Structure

```
terraform-aws-localstack/

├── envs/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── backend.tf
│
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── s3/
│   ├── alb/
│   └── rds/
│
├── .gitignore
└── README.md
```

---

#  Tech Stack

| Technology | Purpose |
|------------|---------|
| Terraform | Infrastructure as Code |
| Ministack | Local AWS cloud emulator |
| Docker | Runs local cloud services |
| AWS Provider | Terraform AWS resource management |
| AWS CLI | Infrastructure verification |
| WSL2 Ubuntu | Development environment |

---

#  Prerequisites

Install:

- Terraform
- Docker
- AWS CLI
- Python

---

#  Installation

## 1. Install Ministack

Using pip:

```bash
pip install ministack
```

Start Ministack:

```bash
ministack
```

Or with Docker:

```bash
docker run \
-p 4566:4566 \
-v /var/run/docker.sock:/var/run/docker.sock \
ministackorg/ministack
```

Verify:

```bash
curl http://localhost:4566/_ministack/health
```

---

#  Deployment

## 1. Create Terraform state bucket

Terraform remote state requires the bucket to exist first:

```bash
awslocal s3 mb s3://terraform-state-bucket
```

---

## 2. Navigate to environment

```bash
cd envs/dev
```

---

## 3. Initialize Terraform

```bash
terraform init -reconfigure
```

---

## 4. Deploy infrastructure

```bash
terraform apply
```

---

#  Verify Resources

Check created resources:

### EC2

```bash
awslocal ec2 describe-instances
```

### Load Balancer

```bash
awslocal elbv2 describe-load-balancers
```

### RDS

```bash
awslocal rds describe-db-instances
```

### S3

```bash
awslocal s3 ls
```

---

# Terraform Backend Configuration

Terraform state is stored remotely inside Ministack S3.

Example:

```hcl
terraform {

 backend "s3" {

    bucket = "terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"

    access_key = "test"
    secret_key = "test"

    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id = true

    use_path_style = true

    endpoints = {
      s3 = "http://localhost:4566"
    }
 }
}
```

---

# 🐛 Challenges & Solutions

This project included many real Terraform debugging scenarios.

## Duplicate module definitions

**Problem**

Modules were accidentally declared in multiple Terraform files.

**Solution**

Module calls belong only in `main.tf`.

---

## Terraform connecting to real AWS

**Problem**

Terraform tried authenticating against AWS instead of Ministack.

**Solution**

Configured fake credentials and local endpoints:

```hcl
access_key = "test"
secret_key = "test"
endpoint = "http://localhost:4566"
```

---

## Missing Terraform state bucket

**Problem**

Terraform backend could not initialize.

**Solution**

Created the bucket manually:

```bash
awslocal s3 mb s3://terraform-state-bucket
```

---

## Wrong module resource references

**Problem**

Modules referenced resources directly instead of using variables and outputs.

Example:

Incorrect:

```hcl
aws_vpc.example.id
```

Correct:

```hcl
var.vpc_id
```

---

## Missing module outputs

**Problem**

Environment outputs referenced values that modules did not expose.

**Solution**

Added Terraform outputs:

```hcl
output "alb_dns_name" {
 value = aws_lb.main.dns_name
}
```

---

## Running Terraform from the wrong directory

**Problem**

Terraform was executed inside:

```
modules/alb
```

instead of:

```
envs/dev
```

**Solution**

Always run Terraform from the environment folder.

---

#  Current Status

The project is fully working locally.

Successfully provisioned:

 VPC  
 Public/private networking  
 EC2 instances  
 Application Load Balancer  
S3 storage  
 RDS database  
 Remote Terraform state using S3 backend  

All resources are managed through Terraform against Ministack.

---

#  Skills Demonstrated

This project demonstrates practical experience with:

- Infrastructure as Code
- Terraform modules
- AWS architecture concepts
- Cloud networking
- Terraform state management
- Debugging cloud deployments
- Containerized cloud environments
- AWS CLI automation

---

#  Credits

Special thanks to the **Ministack open-source project** for providing a free AWS-compatible environment that allows cloud engineers and students to practice infrastructure automation without cloud costs.
