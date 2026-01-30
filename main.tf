provider "aws" {
  region = var.region
}

# SNS Topic
resource "aws_sns_topic" "alert_topic" {
  name = "ec2-restart-alert"
}

# SNS Email subscription
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = "ns476280@gmail.com"
}

# IAM Role for Lambda (least privilege)
resource "aws_iam_role" "lambda_role" {
  name = "lambda-ec2-restart-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-ec2-restart-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:RebootInstances"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.alert_topic.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# EC2 Instance
resource "aws_instance" "demo_ec2" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "terraform-demo-ec2"
  }
}

# Zip Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda.zip"
}

# Lambda Function
resource "aws_lambda_function" "restart_lambda" {
  function_name = "restart-ec2-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      INSTANCE_ID   = aws_instance.demo_ec2.id
      SNS_TOPIC_ARN = aws_sns_topic.alert_topic.arn
    }
  }
}
