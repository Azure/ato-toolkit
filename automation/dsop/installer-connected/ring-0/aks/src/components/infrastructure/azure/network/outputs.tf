output "vnet_id" {
  value = azurerm_virtual_network.network.id
}

output "subnet_id" {
  value = azurerm_subnet.worker_subnet.id
}

output "ssh_key_location" {
  value = local_file.private_ssh_key.filename
}

output "jumphost_user" {
  value = "systemadmin"
}

output "jumphost_ip" {
  value = data.azurerm_public_ip.jumphost_pip.ip_address
}
