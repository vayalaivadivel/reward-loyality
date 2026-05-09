resource "aws_cloudwatch_event_rule" "daily_trigger" {

  name = "daily-hop-trigger"

  schedule_expression = "cron(0 1 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {

  rule = aws_cloudwatch_event_rule.daily_trigger.name

  arn = var.lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {

  statement_id = "AllowExecutionFromEventBridge"

  action = "lambda:InvokeFunction"

  function_name = var.lambda_name

  principal = "events.amazonaws.com"

  source_arn = aws_cloudwatch_event_rule.daily_trigger.arn
}