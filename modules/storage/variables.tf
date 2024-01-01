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

variable "queue_delay_seconds" {
    type = number
    description = "Number of seconds to delay the message"
}

variable "queue_max_message_size" {
    type = number
    description = "Max message size of the SQS queue"
}

variable "queue_message_retention_seconds" {
    type = number
    description = "Number of seconds to retain a message"
}

variable "queue_receive_message_wait_time_seconds" {
    type = number
    description = "Wait time seconds for the SQS queue"
}

variable "queue_redrive_policy_max_receive_count" {
    type = number
    description = "Max number of times a message can be received"
}

variable "tags" {
    type = map(string)
    default = {}
    description = "Tags to apply to all resources"
}