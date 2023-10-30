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

locals {

}

module "network" {
  source        = "./modules/network"
  main_vpc_name = "main"
  main_vpc_cidr = "10.10.0.0/16"
  public_subnet_a_cidr = "10.10.0.0/24"
  public_subnet_b_cidr = "10.10.1.0/24"
  private_subnet_a_cidr = "10.10.2.0/24"
  private_subnet_b_cidr = "10.10.3.0/24"
}