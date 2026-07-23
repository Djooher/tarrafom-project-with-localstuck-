# Terraform AWS Ministack — Local Cloud Infrastructure Demo

A hands-on portfolio project that provisions a small AWS-style infrastructure stack (VPC, EC2, S3, ALB, RDS) entirely **locally**, using Terraform and a free, open-source AWS emulator — no real AWS account or billing required.

## Why this project exists

This started as a way to practice real Infrastructure-as-Code workflows (Terraform modules, remote state, multi-tier apps) without needing a paid AWS account.

Originally I planned to use **LocalStack**, the most popular local AWS emulator. However, LocalStack has since moved most of its core AWS services (EC2, RDS, ALB, etc.) behind a **paid Pro plan** — the free Community edition no longer covers what this project needs.

So instead, I used **[Ministack](https://github.com/ministackorg/ministack)** — a free, open-source, MIT-licensed alternative that emulates 60+ AWS services (including EC2, RDS, ALB, S3, VPC) locally, is fully compatible with Terraform, the AWS CLI, and boto3, and even spins up **real Postgres/MySQL containers** for RDS instead of just mocking responses.

This README documents the setup, the architecture, and the (many, very real) errors I ran into along the way — partly for recruiters/reviewers, and partly as a reference for my future self or anyone else learning Terraform the hard way.

## What this project builds

A small multi-tier "app" infrastructure, split into reusable Terraform modules:

| Module | What it creates |
|---|---|
| `vpc`   | A VPC with public + private subnets |
| `s3`    | An S3 bucket |
| `ec2`   | A security group + EC2 instance(s) running a simple web server |
| `alb`   | An Application Load Balancer in front of the EC2 instances |
| `rds`   | A database instance in the private subnet |

All modules live under `modules/`, and are wired together per environment under `envs/<env-name>/` (currently just `dev`).

## Tech stack

- **Terraform** (`~> 5.0` AWS provider)
- **[Ministack](https://github.com/ministackorg/ministack)** — free local AWS emulator (drop-in LocalStack alternative), running on `http://localhost:4566`
- **WSL2 / Ubuntu** on Windows
- Terraform S3 backend (pointed at Ministack, not real AWS) for remote state

## Prerequisites

- Terraform installed
- Docker (for Ministack + RDS/EC2 containers)
- Ministack running locally:
  ```bash
  pip install ministack
  ministack
  # or: docker run -p 4566:4566 -v /var/run/docker.sock:/var/run/docker.sock ministackorg/ministack
  ```
- Verify it's up:
  ```bash
  curl http://localhost:4566/_ministack/health
  ```

## How to run it

```bash
# 1. Create the state bucket in Ministack (S3 backend needs this to already exist)
awslocal s3 mb s3://terraform-state-bucket

# 2. Go to the dev environment
cd envs/dev

# 3. Init + apply
terraform init -reconfigure
terraform apply
```

Check what got created:
```bash
awslocal ec2 describe-instances
awslocal elbv2 describe-load-balancers
awslocal rds describe-db-instances
awslocal s3 ls
```

## Provider & backend config (pointed at Ministack, not AWS)

Both the Terraform backend and the AWS provider need fake credentials and Ministack's local endpoint instead of real AWS:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"

    access_key                  = "test"
    secret_key                  = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style               = true

    endpoints = {
      s3 = "http://localhost:4566"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  endpoints {
    ec2      = "http://localhost:4566"
    s3       = "http://localhost:4566"
    rds      = "http://localhost:4566"
    elbv2    = "http://localhost:4566"
    iam      = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
  }
}
```

## Lessons learned / bugs fixed along the way

Building this taught me a lot about how Terraform actually validates configuration — here's the trail of real errors I hit and fixed, in order:

1. **Duplicate module definitions** — module blocks (`vpc`, `s3`, `ec2`, `alb`, `rds`) were accidentally pasted into both `main.tf` and `variables.tf`. Fix: module calls only belong in `main.tf`; `variables.tf` should only contain `variable` declarations.
2. **Single-line block syntax errors** — several `variable "x" { type = string  default = "y" }` declarations crammed two arguments onto one line, which HCL doesn't allow. Fix: split each argument onto its own line inside the block.
3. **Missing variable declarations** — some modules (`s3`, `alb`) referenced variables in `main.tf` that were never declared in that module's own `variables.tf`, causing "Unsupported argument" errors.
4. **S3 backend pointed at real AWS** — the `backend "s3"` block had no fake credentials or endpoint override, so Terraform tried to authenticate against real AWS and failed with `InvalidAccessKeyId`. Fix: added `access_key`, `secret_key`, and `endpoints { s3 = "http://localhost:4566" }` to the backend block itself (the AWS provider block's settings don't apply to backend operations).
5. **Missing state bucket** — the S3 backend needs its bucket to already exist; it won't auto-create it. Fixed by running `awslocal s3 mb s3://terraform-state-bucket` first.
6. **Bad brace nesting** — the `provider "aws" {}` block ended up nested inside `terraform {}` due to a missing closing brace, which Terraform doesn't allow (`provider` blocks must be top-level).
7. **Wrong resource references inside a module** — `modules/ec2/main.tf` referenced a non-existent local `aws_vpc.aws_vpc.id` instead of the `var.vpc_id` passed in from the `vpc` module's output.
8. **Missing module outputs** — `envs/dev/outputs.tf` referenced `module.alb.alb_dns_name`, but the `alb` module never declared that as an output, so it didn't exist to reference.
9. **Running `terraform apply` from inside a module folder** — modules are building blocks, not standalone root configs. Running Terraform directly inside `modules/alb` caused it to demand manual values for things normally wired automatically from other modules. Always run Terraform from `envs/dev`, never from inside `modules/*`.

## Status

Working end-to-end against Ministack locally: VPC, EC2, S3, ALB, and RDS all provision successfully with `terraform apply`, and Terraform state is stored remotely in a Ministack-backed S3 bucket.

## Credits

- [Ministack](https://github.com/ministackorg/ministack) — free, open-source local AWS emulator that made this possible without a paid LocalStack plan.
