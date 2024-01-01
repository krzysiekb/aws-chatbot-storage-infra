resource "aws_sqs_queue" "chtbot_storage_queue" {
  name                      = var.queue_name
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.chtbot_storage_queue_deadletter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "chtbot_storage_queue_deadletter" {
  name = var.queue_dlq_name
}