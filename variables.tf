variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "api_gateway_id" {
  description = "ID of the shared API Gateway"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to the zipped Lambda code"
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs20.x"
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "vpc_id" {
  description = "VPC ID to attach the Lambda to (optional)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC attachment (optional)"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda"
  type        = map(string)
  default     = {}
}

variable "path_pattern" {
  description = "API Gateway route path pattern (e.g., /myservice)"
  type        = string
  default     = null
}
