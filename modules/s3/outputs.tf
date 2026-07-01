output "bucket_name" {
  description = "The S3 reports bucket name"
  value       = aws_s3_bucket.reports.id
}

output "bucket_arn" {
  description = "The S3 reports bucket ARN"
  value       = aws_s3_bucket.reports.arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for S3 encryption"
  value       = aws_kms_key.s3_key.arn
}
