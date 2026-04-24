resource "aws_sqs_queue" "start_payment_q" {
  name = "start-payment-queue"
}

resource "aws_sqs_queue" "check_balance_q" {
  name = "check-balance-queue"
}

resource "aws_sqs_queue" "transaction_q" {
  name = "transaction-queue"
}