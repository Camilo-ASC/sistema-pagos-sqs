data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../dist"
  output_path = "${path.module}/payload.zip"
}

# --- Lambda 1: Start Payment ---
resource "aws_lambda_function" "start_payment" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "start-payment"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "handlers/start-payment.handler"
  runtime       = "nodejs18.x"

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      REDIS_URL               = var.redis_url
      CHECK_BALANCE_QUEUE_URL = aws_sqs_queue.check_balance_q.id
    }
  }
}

resource "aws_lambda_event_source_mapping" "trigger_start" {
  event_source_arn = aws_sqs_queue.start_payment_q.arn
  function_name    = aws_lambda_function.start_payment.arn
}

# --- Lambda 2: Check Balance ---
resource "aws_lambda_function" "check_balance" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "check-balance"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "handlers/check-balance.handler"
  runtime       = "nodejs18.x"

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      REDIS_URL             = var.redis_url
      TRANSACTION_QUEUE_URL = aws_sqs_queue.transaction_q.id
    }
  }
}

resource "aws_lambda_event_source_mapping" "trigger_balance" {
  event_source_arn = aws_sqs_queue.check_balance_q.arn
  function_name    = aws_lambda_function.check_balance.arn
}

# --- Lambda 3: Transaction ---
resource "aws_lambda_function" "transaction" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "transaction-service"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "handlers/transaction.handler"
  runtime       = "nodejs18.x"

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      REDIS_URL = var.redis_url
    }
  }
}

resource "aws_lambda_event_source_mapping" "trigger_tx" {
  event_source_arn = aws_sqs_queue.transaction_q.arn
  function_name    = aws_lambda_function.transaction.arn
}