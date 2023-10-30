resource "aws_vpc" "main" {
    cidr_block = var.main_vpc_cidr
    tags = {
      "Name" = var.main_vpc_name
    }
}

data "aws_availability_zones" "availability_zones" {
  state = "available"
}