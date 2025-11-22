# terraform-aws-lambda-service

## Purpose

This module provisions a **Lambda-based microservice** with API Gateway integration. It supports both public (no VPC) and private (VPC-attached) configurations.

## Usage

### Multi-Function Service (Recommended)

```hcl
locals {
  lambdas = {
    "hello" = { handler = "functions/hello.handler", path = "/hello" }
    "bye"   = { handler = "functions/bye.handler",   path = "/bye" }
  }
}

module "functions" {
  source   = "git::https://github.com/TheBitDrifter/terraform-aws-lambda-service.git?ref=main"
  for_each = local.lambdas

  service_name    = "${var.service_name}-${each.key}"
  environment     = var.environment
  api_gateway_id  = "api-12345"
  lambda_zip_path = "./function.zip"
  
  handler      = each.value.handler
  path_pattern = "/${var.service_name}${each.value.path}"
}
```

### Private Lambda (VPC Attached)

```hcl
module "my_private_service" {
  source = "git::https://github.com/TheBitDrifter/terraform-aws-lambda-service.git?ref=main"

  service_name    = "my-private-service"
  environment     = "prod"
  api_gateway_id  = "api-12345"
  lambda_zip_path = "./function.zip"
  
  vpc_id          = "vpc-12345"
  subnet_ids      = ["subnet-a", "subnet-b"]
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `service_name` | Name of the service | `string` | Required |
| `environment` | Deployment environment | `string` | Required |
| `api_gateway_id` | Shared API Gateway ID | `string` | Required |
| `lambda_zip_path` | Path to zip file | `string` | Required |
| `vpc_id` | VPC ID (optional) | `string` | `null` |
| `subnet_ids` | Subnet IDs (optional) | `list(string)` | `[]` |
| `path_pattern` | Custom route path | `string` | `/{service_name}/{proxy+}` |
