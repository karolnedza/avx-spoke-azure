####################################################################
# Azure Ubuntu Instance
resource "azurerm_resource_group" "aviatrix-rg" {
  count = (var.cloud_type == "azure") ? 1 : 0
  name     = "rg-${var.vm_name}"
 # location = var.azure_cloud_region
  location = var.cloud_region["${var.aviatrix_transit_gateway}"]
}

resource "azurerm_public_ip" "avtx-public-ip" {
  count = (var.cloud_type == "azure") ? 1 : 0
  name                = "public-ip-${var.vm_name}"
  location            = azurerm_resource_group.aviatrix-rg[0].location
  resource_group_name = azurerm_resource_group.aviatrix-rg[0].name
  allocation_method   = "Dynamic"
 }

resource "azurerm_network_interface" "iface" {
  count = (var.cloud_type == "azure") ? 1 : 0
  name                = "nic-${var.vm_name}"
  location            = azurerm_resource_group.aviatrix-rg[0].location
  resource_group_name = azurerm_resource_group.aviatrix-rg[0].name

  ip_configuration {
    name                          = "avtx_internal-${var.vm_name}"
    #subnet_id     = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${split(":", aviatrix_vpc.aviatrix_vpc_vnet.vpc_id)[1]}/providers/Microsoft.Network/virtualNetworks/${split(":", aviatrix_vpc.aviatrix_vpc_vnet.vpc_id)[0]}/subnets/${aviatrix_vpc.aviatrix_vpc_vnet.subnets[0].subnet_id}"
    subnet_id = aviatrix_vpc.aviatrix_vpc_vnet.subnets[0].subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.avtx-public-ip[0].id

  }
}


resource "azurerm_linux_virtual_machine" "azure-spoke-vm" {
  count = (var.cloud_type == "azure") ? 1 : 0
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.aviatrix-rg[0].name
  location            = azurerm_resource_group.aviatrix-rg[0].location
  size                = "Standard_B1s"
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.iface[0].id,
  ]

  admin_password = "Aviatrix123#"
  disable_password_authentication = "false"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


# resource "aws_route53_record" "azure_vm_fqdn" {
#   count = (var.cloud_type == "azure") ? 1 : 0
#   zone_id    = data.aws_route53_zone.pub.zone_id
#   name       = "${var.vm_name}.mcna.cc"
#   type       = "A"
#   ttl        = "300"
#   records    = [azurerm_public_ip.avtx-public-ip[0].ip_address]
# }