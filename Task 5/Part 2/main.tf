# Designate a cloud provider, region, and credentials
provider "aws" {
  access_key = "xxx"
  secret_key = "xxx"
  region = var.aws_region
}

# Create a zip file so we can deploy to AWS Lambda
provider "archive" {}
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "greet_lambda.zip"
}

# Create IAM Policy Document and Role for Lambda
data "aws_iam_policy_document" "role_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_lambda_role" {
  name               = "iam_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.role_policy.json
}

# Create AWS Lambda resource
resource "aws_lambda_function" "greet_function" {
  function_name     = "greet_lambda"
  filename          = data.archive_file.lambda_zip.output_path
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
  role              = aws_iam_role.iam_lambda_role.arn
  handler           = "greet_lambda.lambda_handler"
  runtime = "python3.9"
  environment {
    variables = {
      greeting = "Hey!!"
    }
  }
}

# Create AWS Cloudwatch Log Group resource
resource "aws_cloudwatch_log_group" "greet_lambda_log_group" {
  name              = "/aws/lambda/greet_function.function_name"
  retention_in_days = 14
}

# Create AWS Policy Document for Logs
data "aws_iam_policy_document" "lambda_log_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# Create AWS Policy for Logs
resource "aws_iam_policy" "lambda_log_policy" {
  name        = "lambda_logs"
  path        = "/"
  description = "IAM policy for logging from lambda function"
  policy      = data.aws_iam_policy_document.lambda_log_policy_document.json
}

# Attach Policy for Logs to IAM Role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_lambda_role.name
  policy_arn = aws_iam_policy.lambda_log_policy.arn
}