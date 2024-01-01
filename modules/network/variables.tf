variable "main_vpc_name" {
    type = string
    description = "Main VPC name"
}

variable "main_vpc_cidr" {
    type = string
    description = "Main VPC CIDR"
}

variable "public_subnet_a_cidr" {
  type = string
  description = "Public Subnet A CIDR"
}

variable "public_subnet_b_cidr" {
  type = string
  description = "Public Subnet B CIDR"
}

variable "private_subnet_a_cidr" {
  type = string
  description = "Private Subnet A CIDR"
}

variable "private_subnet_b_cidr" {
  type = string
  description = "Private Subnet B CIDR"
}