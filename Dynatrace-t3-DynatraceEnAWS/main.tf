terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true
  skip_requesting_account_id  = true


  endpoints {
    s3     = "http://localhost:4566"
    lambda = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-lambda-dt"
}

resource "aws_lambda_function" "send_event_to_dynatrace" {
  function_name = "send-dt-event"
  role          = "arn:aws:iam::000000000000:role/lambda-ex" # <- rol simulado
  handler       = "handler.lambda_handler"
  runtime       = "python3.10"

  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      DT_API_TOKEN = var.dt_api_token
      DT_ENV_URL   = var.dt_env_url
    }
  }
}


resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_event_to_dynatrace.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.send_event_to_dynatrace.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}


