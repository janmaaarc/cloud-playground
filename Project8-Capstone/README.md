# Project 8 – Capstone Project  
**Title:** AWS Cloud Infrastructure using Terraform  

---

## Objectives  
- Combine multiple AWS services into a single integrated cloud environment.  
- Deploy and manage infrastructure using **Terraform (IaC)**.  
- Implement and connect **EC2, S3, Lambda, API Gateway, VPC, IAM**, and **CloudWatch**.  
- Ensure scalability, automation, and monitoring across all components.  
- Version control all IaC scripts using **GitHub**.

---

## Architecture Overview  

The architecture integrates multiple AWS services working together:

- **VPC** – Provides a secure, isolated network environment.  
- **Public Subnet** – Hosts the EC2 instance accessible via SSH/HTTP.  
- **EC2 Instance** – Web server or app host deployed within the VPC.  
- **S3 Bucket** – Stores data, logs, or application assets.  
- **Lambda Function** – Serverless function that can be triggered via API Gateway.  
- **API Gateway** – Provides REST endpoint to invoke the Lambda function.  
- **IAM Roles & Policies** – Securely grant permissions to Lambda and EC2.  
- **CloudWatch** – Monitors logs and metrics from Lambda and EC2.  
- **Terraform** – Automates and manages all the infrastructure creation and updates.

---

##  Architecture Diagram  

![AWS Architecture](A_detailed_AWS_cloud_architecture_diagram_illustra.png)

> This diagram illustrates the relationship between EC2, S3, Lambda, API Gateway, IAM, VPC, and CloudWatch — all provisioned via Terraform.

---

## Tools and Technologies  
| Category | Tools/Services Used |
|-----------|---------------------|
| Cloud Platform | AWS |
| Infrastructure as Code | Terraform |
| Compute | EC2, Lambda |
| Storage | S3 |
| Networking | VPC, Subnets, Internet Gateway |
| Access Management | IAM |
| Monitoring | CloudWatch |
| API Integration | API Gateway |
| Version Control | Git & GitHub |

---

## Folder Structure
```
Project8-Capstone/
│
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
│
├── vpc.tf
├── ec2.tf
├── s3.tf
├── iam.tf
├── lambda.tf
├── apigateway.tf
├── cloudwatch.tf
│
└── lambda_function.py
```

---

## 🪄 Terraform Configuration Files  

### provider.tf
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "ap-southeast-1"
}
```

### variables.tf
```hcl
variable "project_name" {
  default = "capstone-project8"
}

variable "instance_type" {
  default = "t2.micro"
}
```

### vpc.tf
```hcl
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
}
```

### ec2.tf
```hcl
resource "aws_security_group" "ec2_sg" {
  name   = "${var.project_name}-ec2-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = "ami-0df7a207adb9748c7"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
```

### s3.tf
```hcl
resource "aws_s3_bucket" "project_bucket" {
  bucket = "${var.project_name}-bucket"
  acl    = "private"
}
```

### iam.tf
```hcl
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
```

### lambda.tf
```hcl
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "lambda_func" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
}
```

### apigateway.tf
```hcl
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api"
  description = "API Gateway for Lambda"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "invoke"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda_func.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "apigateway.amazonaws.com"
}
```

### cloudwatch.tf
```hcl
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_func.function_name}"
  retention_in_days = 14
}
```

### lambda_function.py
```python
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda via API Gateway!'
    }
```

### outputs.tf
```hcl
output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.project_bucket.id
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.api.id
}
```

---

## Commands used
```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

## Notes/Lessons Learned

- Terraform automates provisioning, reducing manual setup and errors.
- AWS IAM ensures secure and controlled access between services.
- Using CloudWatch improves visibility and debugging of serverless apps.
- IaC enables version-controlled, repeatable deployments for cloud systems.
- Integrating EC2, Lambda, and API Gateway builds a complete cloud workflow.

---

## Screenshots

	•	Terraform plan and apply output
	•	AWS Console resources: EC2, S3, Lambda, API Gateway
	•	CloudWatch logs and metrics
