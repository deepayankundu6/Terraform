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

variable "Instance_type" {
  type    = string
  default = "db.t3.micro"
}

variable "Access_Key_Name" {
  type    = string
  default = "Deep_Key"
}

variable "SG_Name" {
  type    = string
  default = "allow_RDS"
}

variable "Db_Name" {
  type    = string
  default = "MyDB"
}

variable "User_Name" {
  type    = string
  default = "deepayan024"
}

variable "Password" {
  type    = string
  default = "password123"
}

resource "aws_vpc" "my_VPC" {
  cidr_block = "192.168.0.0/16"
}

resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.my_VPC.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "ap-south-1c"
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.my_VPC.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "ap-south-1b"
}

resource "aws_subnet" "public-1" {
  vpc_id            = aws_vpc.my_VPC.id
  cidr_block        = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
}

resource "aws_internet_gateway" "ig-1" {
  vpc_id = aws_vpc.my_VPC.id
}

resource "aws_eip" "eip-1" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-1.id
  subnet_id     = aws_subnet.public-1.id
}

resource "aws_db_subnet_group" "private-sg" {
  name       = "private-sg1"
  subnet_ids = [aws_subnet.private-1.id, aws_subnet.private-2.id]
}

resource "aws_security_group" "allow_tls_RDS" {
  name        = var.SG_Name
  description = "Allow SSH and RDS inbound traffic"
  vpc_id      = aws_vpc.my_VPC.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 0
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "RDS from VPC"
    from_port        = 0
    to_port          = 3306
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

resource "aws_db_instance" "RDS_Instance" {
  allocated_storage    = 50
  db_name              = var.Db_Name
  engine               = "mysql"
  instance_class       = var.Instance_type
  username             = var.User_Name
  password             = var.Password
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.private-sg.name
  apply_immediately    = true
}

output "DB_ip_address" {
  description = "IP address of the newly created DB instance"
  value       = "DB instance created with private ip address: ${aws_db_instance.RDS_Instance.address}"
}
