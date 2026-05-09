resource "aws_lambda_function" "hop_trigger" {

  function_name = "hop-workflow-trigger"

  filename = "${path.module}/lambda/function.zip"

  source_code_hash = filebase64sha256(
    "${path.module}/lambda/function.zip"
  )

  role    = var.lambda_role_arn
  handler = "trigger_hop.lambda_handler"
  runtime = "python3.11"

  timeout = 60

  environment {
    variables = {
      HOP_URL      = var.hop_url
      HOP_USERNAME = var.hop_username
      HOP_PASSWORD = var.hop_password
    }
  }
}