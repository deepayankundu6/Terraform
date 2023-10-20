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

variable "Public_Instance_type" {
  type = string
}

variable "Access_Key_Name" {
  type = string
}

variable "SG_Name" {
  type = string
}

variable "AMI_Name" {
  type = string
}

resource "aws_vpc" "my_VPC" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.my_VPC.id
  cidr_block              = "10.0.0.0/25"
  map_public_ip_on_launch = "true"
}

resource "aws_internet_gateway" "ig-1" {
  vpc_id = aws_vpc.my_VPC.id
}

resource "aws_security_group" "allow_tls" {
  name        = var.SG_Name
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.my_VPC.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 0
    to_port          = 22
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

resource "aws_instance" "myInstance-public" {
  ami                    = var.AMI_Name
  instance_type          = var.Public_Instance_type
  key_name               = var.Access_Key_Name
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  subnet_id              = aws_subnet.public-1.id
  tags = {
    onwer = "Deepayan Kundu"
  }
}

output "Public_ip_address" {
  description = "Public ip address of the newly created instance"
  value = "EC2 instance created with public ip address: ${aws_instance.myInstance-public.public_ip}"
}