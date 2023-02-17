provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

data "archive_file" "pandas_lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

resource "aws_iam_role" "pandas_lambda" {
  name = "pandas-lambda-test"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/lambda/pandas_layer.zip"
  layer_name = "testingpandas"

  compatible_runtimes = ["python3.8"]
  compatible_architectures = ["x86_64"]
}

resource "aws_lambda_function" "pandas_lambda" {
  filename      = data.archive_file.pandas_lambda.output_path
  source_code_hash = data.archive_file.pandas_lambda.output_base64sha256
  function_name = "pandas_lambda"
  role          = aws_iam_role.pandas_lambda.arn
  handler       = "lambda_function.lambda_handler"

  runtime = "python3.8"

  layers = [aws_lambda_layer_version.lambda_layer.arn]

}
