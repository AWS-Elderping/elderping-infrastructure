# Outputs configurations
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_db_endpoint" {
  value = module.rds.db_endpoint
}

output "cognito_user_pool_id" {
  value = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  value = module.cognito.user_pool_client_id
}

output "reports_s3_bucket_name" {
  value = module.s3.bucket_name
}

output "route53_nameservers" {
  description = "Nameservers for elderping.online zone delegation"
  value       = module.route53.name_servers
}

output "github_actions_role_arn" {
  description = "The ARN of the GitHub Actions IAM role for OIDC access"
  value       = module.github_oidc.github_actions_role_arn
}

output "s3_reports_role_arn" {
  description = "The ARN of the EKS S3 patient reports IAM role"
  value       = module.eks.s3_reports_role_arn
}
