variable "vpc_id" {
  type        = string
  description = "VPC ID where Lambda attaches"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets for VPC attachment"
}

variable "reports_bucket_arn" {
  type        = string
  description = "ARN of the S3 reports bucket (source of document upload events)"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "rds_host" {
  type        = string
  description = "Real RDS endpoint address (not a Kubernetes-internal service name - the Lambda is not part of the cluster's DNS namespace)"
}

variable "lambda_package_path" {
  type        = string
  description = "Path to the built deployment zip (see elderping-doc-embedder-lambda/README.md for build instructions)"
}
