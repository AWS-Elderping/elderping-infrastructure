# ElderPing Infrastructure (Infrastructure as Code)

This repository contains all modular Terraform configuration files used to provision and manage AWS resources for the ElderPing platform.

---

## Directory Structure

```text
elderping-infra/
├── environments/
│   └── dev/                  # Development environment configuration
│       ├── main.tf           # Environment root declaration
│       ├── variables.tf      # Inputs declarations
│       └── outputs.tf        # Output parameter exports
│
├── modules/                  # Reusable Terraform Modules
│   ├── alb/                  # Application Load Balancer module
│   ├── argocd-bootstrap/     # EKS ArgoCD bootstrapping helm resources
│   ├── aws-config/           # AWS Config rules and channel setup
│   ├── budgets/              # AWS Budget cost monitors
│   ├── cloudfront/           # CloudFront CDN configuration
│   ├── cloudtrail/           # Audit trails & CloudTrail setup
│   ├── cloudwatch/           # CloudWatch log group & KMS setups
│   ├── cognito/              # Cognito UserPool & Client provisioning
│   ├── cost-explorer/        # Cost anomaly monitors
│   ├── ecr/                  # ECR Private registry configurations
│   ├── eks/                  # EKS cluster, node groups, and IAM roles
│   ├── eventbridge/          # CloudWatch Events & Scheduler triggers
│   ├── external-secrets/     # External Secrets Operator configuration
│   ├── guardduty/            # GuardDuty threat detector setup
│   ├── inspector/            # AWS Inspector security scans
│   ├── lambda/               # Trigger logic zip and configuration
│   ├── rds/                  # Multi-AZ RDS Postgres DB creation
│   ├── route53/              # Route 53 DNS hosted zones
│   ├── s3/                   # S3 logs & storage buckets
│   ├── security-hub/         # Security Hub subscription activation
│   ├── ses/                  # Simple Email Service domain configurations
│   ├── sns/                  # SNS Topic for notifications
│   ├── sqs/                  # SQS queues for microservice coordination
│   ├── vpc/                  # VPC and route networks configuration
│   ├── vpc-endpoints/        # AWS PrivateLink network gateways
│   ├── waf/                  # WAF Web ACL rules
│   │
│   ├── acm/                  # ACM Certificates with DNS validation (Extracted)
│   ├── iam/                  # Common IAM roles & policies (Placeholder)
│   ├── secrets-manager/      # Secrets Manager configurations (Placeholder)
│   └── redis/                # ElastiCache Redis replication setup (Placeholder)
│
└── .github/
    └── workflows/            # Terraform CI/CD pipelines (Plan and Apply)
```

---

## Deployment Instructions

### Prerequisites
* Terraform (v1.7.0+) installed.
* AWS CLI installed and configured with appropriate permissions.

### Steps
1. Navigate to the dev environment:
   ```bash
   cd environments/dev
   ```
2. Initialize backend and providers:
   ```bash
   terraform init
   ```
3. Check execution plan:
   ```bash
   terraform plan
   ```
4. Deploy the infrastructure:
   ```bash
   terraform apply
   ```

---

## CI/CD Workflow
* **PR Plan**: Every pull request targeting the `main` branch triggers `terraform-plan.yml`, which executes `terraform validate` and `terraform plan`.
* **Merge Apply**: When a PR is successfully merged, `terraform-apply.yml` triggers `terraform apply -auto-approve` to roll out changes to AWS.
