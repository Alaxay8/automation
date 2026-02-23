variable "inventory_path" {
  type = string
}

variable "all_public_ips" {
  type = list(string)
}

variable "host_prefix" {
  type = string
}

variable "ansible_user" {
  type    = string
  default = "ec2-user"
}

variable "ansible_ssh_private_key_file" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "ansible_ssh_common_args" {
  type    = string
  default = "-o StrictHostKeyChecking=no"
}
