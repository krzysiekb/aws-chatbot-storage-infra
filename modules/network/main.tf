resource "aws_vpc" "main" {
    cidr_block = var.main_vpc_cidr
    tags = {
      "Name" = var.main_vpc_name
    }
}

data "aws_availability_zones" "availabile" {
  state = "available"
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_a_cidr
  availability_zone = data.aws_availability_zones.availabile.names[0]
  tags = {
    "Name" = "${var.main_vpc_name}PublicSubnetA"
  }
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_b_cidr
  availability_zone = data.aws_availability_zones.availabile.names[0]
  tags = {
    "Name" = "${var.main_vpc_name}PublicSubnetB"
  }
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_a_cidr
  availability_zone = data.aws_availability_zones.availabile.names[0]
  tags = {
    "Name" = "${var.main_vpc_name}PrivateSubnetA"
  }
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_b_cidr
  availability_zone = data.aws_availability_zones.availabile.names[0]
  tags = {
    "Name" = "${var.main_vpc_name}PrivateSubnetB"
  }
}