# Doc Embedder Lambda Module
# S3-triggered Python Lambda: extracts text from uploaded medical PDFs,
# chunks it, embeds each chunk with Amazon Titan, and stores the result in
# ai-service's document_embeddings (pgvector) table for RAG chatbot retrieval.

resource "aws_security_group" "doc_embedder_lambda" {
  name        = "elderpinq-${var.environment}-doc-embedder-lambda-sg"
  description = "Doc embedder Lambda execution security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elderpinq-${var.environment}-doc-embedder-lambda-sg"
  }
}

resource "aws_iam_role" "doc_embedder_lambda" {
  name = "elderpinq-${var.environment}-doc-embedder-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.doc_embedder_lambda.name
}

resource "aws_iam_role_policy" "doc_embedder_lambda" {
  name = "elderpinq-${var.environment}-doc-embedder-lambda-policy"
  role = aws_iam_role.doc_embedder_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
      },
      {
        # Kept for the commented-out Amazon Textract extraction path
        # (see elderping-doc-embedder-lambda/src/extractor.py) - not used at
        # runtime today, but granted so it can be re-enabled without an IAM change.
        Effect   = "Allow"
        Action   = ["textract:DetectDocumentText", "textract:AnalyzeDocument"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${var.reports_bucket_arn}/documents/*"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:us-east-1:462355914183:secret:elderpinq/${var.environment}/db-*"
      }
    ]
  })
}

resource "aws_lambda_function" "doc_embedder" {
  filename         = var.lambda_package_path
  function_name    = "elderpinq-${var.environment}-doc-embedder"
  role             = aws_iam_role.doc_embedder_lambda.arn
  handler          = "handler.lambda_handler"
  source_code_hash = filebase64sha256(var.lambda_package_path)
  runtime          = "python3.12"
  timeout          = 60
  memory_size      = 512

  vpc_config {
    subnet_ids         = var.private_subnets
    security_group_ids = [aws_security_group.doc_embedder_lambda.id]
  }

  environment {
    variables = {
      ENVIRONMENT = var.environment
      RDS_HOST    = var.rds_host
      RDS_PORT    = "5432"
      DB_USER     = "elderpinq_admin"
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.doc_embedder.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.reports_bucket_arn
}
