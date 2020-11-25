
output "public_ip_address_windows" {
  value = azurerm_public_ip.windows-public-ip.ip_address
}

output "private_ip_address_windows" {
value = azurerm_network_interface.win-iface.private_ip_address
}


output "public_ip_address_ubuntu" {
  value = azurerm_public_ip.ubuntu-public-ip.ip_address
}

output "private_ip_address_ubuntu" {
value = azurerm_network_interface.iface.private_ip_address
}
