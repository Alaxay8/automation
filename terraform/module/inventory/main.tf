resource "local_file" "this" {
  filename = var.inventory_path

  content = templatefile("${path.module}/inventory.tmpl", {
    all_public_ips               = var.all_public_ips
    host_prefix                  = var.host_prefix
    ansible_user                 = var.ansible_user
    ansible_ssh_private_key_file = var.ansible_ssh_private_key_file
    ansible_ssh_common_args      = var.ansible_ssh_common_args
  })
}
