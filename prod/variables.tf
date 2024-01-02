variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "store_message_lambda_zip_file" {
  type = string
  default = "lambda/store-message/build/store-message.zip"
}