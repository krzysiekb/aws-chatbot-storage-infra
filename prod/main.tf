terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

module "chatbot_network" {
  source        = "../modules/network"
  main_vpc_name = "ChatbotStorageVPC"
  main_vpc_cidr = "10.10.0.0/16"
  public_subnet_a_cidr = "10.10.0.0/24"
  public_subnet_b_cidr = "10.10.1.0/24"
  private_subnet_a_cidr = "10.10.2.0/24"
  private_subnet_b_cidr = "10.10.3.0/24"
}

module "chatbot_storage" {
  source        = "../modules/storage"
  main_vpc_id = module.chatbot_network.vpc_id
  queue_name = "ChatbotStroageQueue"
  queue_dlq_name = "ChatbotStorageDLQ"
  queue_delay_seconds = 0
  queue_max_message_size = 2048
  queue_message_retention_seconds = 604800
  queue_receive_message_wait_time_seconds = 10
  queue_redrive_policy_max_receive_count = 3
  store_message_lambda_zip_file = var.store_message_lambda_zip_file
  
  tags = {
    "environment" = "prod"
  }
}