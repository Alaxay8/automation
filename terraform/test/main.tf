provider "aws" {

}

resource "aws_key_pair" "my_auth" {
key_name = "my_ssh_key"
public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "my_amazon" {
count         = 5
ami           = "ami-0532be01f26a3de55"
instance_type = "t3.micro"
key_name      = aws_key_pair.my_auth.key_name
vpc_security_group_ids = [aws_security_group.allow_ssh.id]
tags = {
    Name = "test-amazon${count.index}"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_traffic"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "all_public_ips" {
  value = aws_instance.my_amazon[*].public_ip
}
