provider "aws" {
  region = "us-east-1"
}

variable "allowed_ssh_ip" {
  default = "0.0.0.0/0"
}


resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "test-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "test-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "test-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

resource "aws_key_pair" "my_auth" {
  key_name   = "my_ssh_key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

resource "aws_instance" "my_amazon" {
  count                  = 5
  ami                    = "ami-0532be01f26a3de55"
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.my_auth.key_name
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    Name = "test-amazon${count.index}"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_traffic"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
locals {
  repo_root      = abspath("${path.module}/../..")
  inventory_path = "${local.repo_root}/ansible/test-amazon-inventory.yaml"
}

resource "local_file" "ansible_inventory" {
  filename = local.inventory_path

  content = templatefile("${path.module}/inventory.tmpl", {
    all_public_ips = aws_instance.my_amazon[*].public_ip
  })
}


output "all_public_ips" {
  value = aws_instance.my_amazon[*].public_ip
}
