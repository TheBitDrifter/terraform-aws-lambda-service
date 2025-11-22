# --- IAM ROLE ---
resource "aws_iam_role" "lambda_exec" {
  name = "${var.service_name}-${var.environment}-lambda-role"

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

# Basic Execution Policy (Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC Access Policy (Conditional)
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = var.vpc_id != null ? 1 : 0
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# --- LOGGING ---
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.service_name}-${var.environment}"
  retention_in_days = 30
}

# --- LAMBDA FUNCTION ---
resource "aws_lambda_function" "this" {
  function_name = "${var.service_name}-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_id != null ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = [aws_security_group.lambda_sg[0].id]
    }
  }
}

# --- SECURITY GROUP (Conditional) ---
resource "aws_security_group" "lambda_sg" {
  count       = var.vpc_id != null ? 1 : 0
  name        = "${var.service_name}-${var.environment}-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- API GATEWAY INTEGRATION ---
resource "aws_apigatewayv2_integration" "this" {
  api_id                 = var.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.this.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# --- API GATEWAY ROUTE ---
# Default route: /service_name/*
resource "aws_apigatewayv2_route" "this" {
  api_id    = var.api_gateway_id
  route_key = "ANY ${coalesce(var.path_pattern, "/${var.service_name}/{proxy+}")}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

# --- LAMBDA PERMISSION ---
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/*"
}

# --- DATA SOURCES ---
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
