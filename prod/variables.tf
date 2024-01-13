variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "chatbot_storage_messages_ecr_repo" {
  type = string
  default = "745368277267.dkr.ecr.us-east-1.amazonaws.com/store-message:0.0.1"
}