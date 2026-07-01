# Terraform Dev Environment Setup
terraform {
  required_version = ">= 1.7.0"
  backend "s3" {
    bucket         = "elderpinq-462355914183-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "elderpinq-tfstate-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "elderpinq"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = "platform-team"
    }
  }
}

# GitHub Actions OIDC Module
module "github_oidc" {
  source      = "../../modules/github-oidc"
  environment = var.environment
}

# ACM Certificate with DNS validation
module "acm" {
  source          = "../../modules/acm"
  domain_name     = var.domain_name
  route53_zone_id = module.route53.zone_id
}



provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

# 1. VPC Networking
module "vpc" {
  source      = "../../modules/vpc"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

# 2. EKS Cluster (Kubernetes version 1.31 parameter)
module "eks" {
  source             = "../../modules/eks"
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  environment        = var.environment
  kubernetes_version = var.kubernetes_version
  log_retention_days = var.log_retention_days
  reports_bucket_arn  = module.s3.bucket_arn
  reports_kms_key_arn = module.s3.kms_key_arn
}

# 3. RDS Multi-AZ Databases
module "rds" {
  source          = "../../modules/rds"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_password     = var.db_password
  environment     = var.environment
}

# 4. Cognito Authentication
module "cognito" {
  source      = "../../modules/cognito"
  environment = var.environment
}

# 5. S3 Patient Reports Bucket
module "s3" {
  source      = "../../modules/s3"
  environment = var.environment
}

# 6. ECR Private Repositories
module "ecr" {
  source      = "../../modules/ecr"
  environment = var.environment
}

# 7. ALB Load Balancer
module "alb" {
  source          = "../../modules/alb"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  environment     = var.environment
  certificate_arn = module.acm.certificate_arn
}

# 8. Route 53 DNS (elderping.online Zone)
module "route53" {
  source      = "../../modules/route53"
  domain_name = var.domain_name
  environment = var.environment
}

# 10. WAF Web ACL
module "waf" {
  source      = "../../modules/waf"
  environment = var.environment
}

# 11. SNS Messaging
module "sns" {
  source      = "../../modules/sns"
  environment = var.environment
}

# 12. SES Email (elderping.online delegation)
module "ses" {
  source          = "../../modules/ses"
  domain_name     = var.domain_name
  environment     = var.environment
  route53_zone_id = module.route53.zone_id
}

# 13. SQS Message Queues
module "sqs" {
  source      = "../../modules/sqs"
  environment = var.environment
}

# 14. EventBridge
module "eventbridge" {
  source      = "../../modules/eventbridge"
  lambda_arn  = module.lambda.lambda_arn
  environment = var.environment
}

# 15. Lambda Reports Trigger
module "lambda" {
  source               = "../../modules/lambda"
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnets
  eventbridge_rule_arn = module.eventbridge.rule_arn
  environment          = var.environment
}

# 16. CloudWatch Logs & Alarms
module "cloudwatch" {
  source             = "../../modules/cloudwatch"
  environment        = var.environment
  log_retention_days = var.log_retention_days
}


# 17. CloudTrail
module "cloudtrail" {
  source      = "../../modules/cloudtrail"
  environment = var.environment
}

# 18. Security Hub
module "security_hub" {
  source      = "../../modules/security-hub"
  environment = var.environment
}

# 19. GuardDuty
module "guardduty" {
  source      = "../../modules/guardduty"
  environment = var.environment
}

# 20. Inspector
module "inspector" {
  source      = "../../modules/inspector"
  environment = var.environment
}

# 21. AWS Config
module "aws_config" {
  source      = "../../modules/aws-config"
  environment = var.environment
}

# 22. AWS Budgets alerts
module "budgets" {
  source      = "../../modules/budgets"
  environment = var.environment
}

# 23. Cost Explorer anomaly monitors
module "cost_explorer" {
  source      = "../../modules/cost-explorer"
  environment = var.environment
}

# 24. VPC PrivateLink Endpoints
module "vpc_endpoints" {
  source          = "../../modules/vpc-endpoints"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  route_table_ids = concat([module.vpc.public_route_table_id], module.vpc.private_route_table_ids)
  environment     = var.environment
}

# 25. EKS External Secrets Operator
module "external_secrets" {
  source            = "../../modules/external-secrets"
  eks_cluster_name  = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  environment       = var.environment
}

# 26. ArgoCD Bootstrap App-of-Apps
module "argocd_bootstrap" {
  source           = "../../modules/argocd-bootstrap"
  eks_cluster_name = module.eks.cluster_name
  environment      = var.environment
}

# Route 53 Records for DNS routing integrations
resource "aws_route53_record" "root" {
  zone_id = module.route53.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = "k8s-elderpinqingressg-dbee728d9e-1971631374.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = module.route53.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "k8s-elderpinqingressg-dbee728d9e-1971631374.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  zone_id = module.route53.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "k8s-elderpinqingressg-dbee728d9e-1971631374.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "argocd" {
  zone_id = module.route53.zone_id
  name    = "argocd.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "k8s-elderpinqingressg-dbee728d9e-1971631374.us-east-1.elb.amazonaws.com"
    zone_id                = "Z35SXDOTRQ7X7K"
    evaluate_target_health = true
  }
}

# WAF to ALB Web ACL Association
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = module.alb.alb_arn
  web_acl_arn  = module.waf.web_acl_arn
}

