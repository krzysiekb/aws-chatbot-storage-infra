resource "aws_sqs_queue" "chtbot_storage_queue" {
  name                      = var.queue_name
  delay_seconds             = var.queue_delay_seconds
  max_message_size          = var.queue_max_message_size
  message_retention_seconds = var.queue_message_retention_seconds
  receive_wait_time_seconds = var.queue_receive_message_wait_time_seconds
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.chtbot_storage_queue_deadletter.arn
    maxReceiveCount     = var.queue_redrive_policy_max_receive_count
  })
  
  tags = var.tags
}

resource "aws_sqs_queue" "chtbot_storage_queue_deadletter" {
  name = var.queue_dlq_name
  tags = var.tags
}

resource "aws_dynamodb_table" "chatbot_storage_messages_table" {
  name           = "ChatbotStorageMessages"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "ChatId"

  attribute {
    name = "ChatId"
    type = "S"
  }

  attribute {
    name = "Messages"
    type = "M"
  }

  tags = var.tags
}