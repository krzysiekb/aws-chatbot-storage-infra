variable "main_vpc_id" {
    type = string
    description = "The VPC ID"
}

variable "queue_name" {
    type = string
    description = "Name of the SQS queue"
}

variable "queue_dlq_name" {
    type = string
    description = "Name of the SQS DLQ"
}