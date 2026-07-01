output "lambda_arn" {
  description = "ARN of the doc embedder Lambda function"
  value       = aws_lambda_function.doc_embedder.arn
}

output "lambda_function_name" {
  description = "Name of the doc embedder Lambda function"
  value       = aws_lambda_function.doc_embedder.function_name
}
