variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS will be launched"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets for EKS worker nodes"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, staging, prod)"
  default     = "dev"
}

variable "kubernetes_version" {
  type        = string
  description = "Target Kubernetes version for EKS cluster"
  default     = "1.31"
}

variable "log_retention_days" {
  type        = number
  description = "Retention period for CloudWatch logs in days"
  default     = 90
}

variable "reports_bucket_arn" {
  type        = string
  description = "The ARN of the reports S3 bucket"
}

variable "reports_kms_key_arn" {
  type        = string
  description = "The KMS key ARN for reports bucket"
}

