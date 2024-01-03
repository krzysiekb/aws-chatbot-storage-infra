data "aws_caller_identity" "current" {}

// Messages SQS Queue
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


// Messages DynamoDB Table
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

  tags = var.tags
}


// Store Message Lambda
data "aws_iam_policy_document" "chatbot_storage_messages_lambda_logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "chatbot_storage_messages_lambda_logging_policy" {
  name        = "ChatbotStorageMessagesLambdaLoggingPolicy"
  description = "Policy for lambda cloudwatch logging"
  policy      = data.aws_iam_policy_document.chatbot_storage_messages_lambda_logging.json
}

data "aws_iam_policy_document" "chatbot_storage_messages_lambda_dynamodb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
    ]
    resources = [
      aws_dynamodb_table.chatbot_storage_messages_table.arn,
    ]
  }
}

resource "aws_iam_policy" "chatbot_storage_messages_lambda_dynamodb_policy" {
  name        = "ChatbotStorageMessagesLambdaDynamoDbPolicy"
  description = "Policy for lambda dynamodb access"
  policy      = data.aws_iam_policy_document.chatbot_storage_messages_lambda_dynamodb.json
}

data "aws_iam_policy_document" "chatbot_storage_messages_lambda_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "chatbot_storage_messages_lambda_role" {
  name = "ChtobotStorageMessagesLambdaRole"
  description = "IAM role for lambda function to handle storage of messages"
  assume_role_policy = data.aws_iam_policy_document.chatbot_storage_messages_lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "chatbot_storage_messages_lambda_role_logging_policy_attachment" {
  role       = aws_iam_role.chatbot_storage_messages_lambda_role.id
  policy_arn = aws_iam_policy.chatbot_storage_messages_lambda_logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "chatbot_storage_messages_lambda_role_dynamodb_policy_attachment" {
  role       = aws_iam_role.chatbot_storage_messages_lambda_role.id
  policy_arn = aws_iam_policy.chatbot_storage_messages_lambda_dynamodb_policy.arn
}

resource "aws_lambda_function" "chatbot_storage_messages_lambda" {
  function_name = "ChtobotStorageMessagesLambda"
  description = "Lambda function to handle storage of messages"
  role = aws_iam_role.chatbot_storage_messages_lambda_role.arn
  
  runtime = "go1.x"
  handler = "main"
  filename = var.store_message_lambda_zip_file
}

resource "aws_lambda_event_source_mapping" "chatbot_storage_messages_lambda_event_source" {
  event_source_arn = aws_sqs_queue.chtbot_storage_queue.arn
  function_name = aws_lambda_function.chatbot_storage_messages_lambda.arn
}