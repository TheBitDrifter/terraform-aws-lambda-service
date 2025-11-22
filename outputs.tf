output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}

output "api_gateway_route_key" {
  description = "The route key created in API Gateway"
  value       = aws_apigatewayv2_route.this.route_key
}
