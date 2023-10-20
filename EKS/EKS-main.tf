provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_access_key
}

variable "access_key" {
  type = string
}

variable "secret_access_key" {
  type = string
}

variable "SG_Name" {
  type    = string
  default = "allow_RDS"
}

resource "aws_vpc" "my_VPC" {
  cidr_block = "192.168.0.0/16"
}

resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.my_VPC.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_internet_gateway" "ig-1" {
  vpc_id = aws_vpc.my_VPC.id
}

resource "aws_security_group" "allow_MongoDB" {
  name        = var.SG_Name
  description = "Allow SSH and RDS inbound traffic"
  vpc_id      = aws_vpc.my_VPC.id

  ingress {
    description      = "Access mongodb"
    from_port        = 0
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
