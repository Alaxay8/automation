provider "aws" {
  region = "us-east-1"
}

variable "allowed_ssh_ip" {
  type    = string
  default = "0.0.0.0/0"
}

module "network" {
  source = "../../module/network"

  vpc_cidr_block          = "10.10.0.0/16"
  subnet_cidr_block       = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  vpc_name                = "test-vpc"
  subnet_name             = "test-subnet"
  internet_gateway_name   = "test-igw"
  public_route_table_name = "test-public-rt"
}

module "security" {
  source = "../../module/security"

  vpc_id              = module.network.vpc_id
  allowed_ssh_ip      = var.allowed_ssh_ip
  security_group_name = "allow_ssh_traffic"
  description         = "Allow SSH inbound traffic"
}

module "compute" {
  source = "../../module/compute"

  instance_count         = 5
  ami_id                 = "ami-0532be01f26a3de55"
  instance_type          = "t3.micro"
  key_name               = "my_ssh_key"
  public_key             = file(pathexpand("~/.ssh/id_rsa.pub"))
  subnet_id              = module.network.subnet_id
  vpc_security_group_ids = [module.security.security_group_id]
  instance_name_prefix   = "test-amazon"
}

locals {
  repo_root      = abspath("${path.module}/../../..")
  inventory_path = "${local.repo_root}/ansible/test-amazon-inventory.yaml"
}

resource "local_file" "ansible_inventory" {
  filename = local.inventory_path

  content = templatefile("${path.module}/inventory.tmpl", {
    all_public_ips = module.compute.public_ips
  })
}


output "all_public_ips" {
  value = module.compute.public_ips
}
