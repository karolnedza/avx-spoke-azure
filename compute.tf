####################################################################
# Azure Ubuntu Instance
################################################################


#### Resource Group

resource "azurerm_resource_group" "aviatrix-rg" {
  name     = "rg-${var.vm_name}"
  location = var.cloud_region["${var.aviatrix_transit_gateway}"]
}

#### Public IP 

resource "azurerm_public_ip" "ubuntu-public-ip" {
  name                = "public-ip-${var.vm_name}"
  location            = azurerm_resource_group.aviatrix-rg.location
  resource_group_name = azurerm_resource_group.aviatrix-rg.name
  allocation_method   = "Dynamic"
 }

#### VM interface 
resource "azurerm_network_interface" "iface" {
  name                = "nic-${var.vm_name}"
  location            = azurerm_resource_group.aviatrix-rg.location
  resource_group_name = azurerm_resource_group.aviatrix-rg.name

  ip_configuration {
    name                          = "avtx_internal-${var.vm_name}"
    subnet_id = aviatrix_vpc.aviatrix_vpc_vnet.subnets[1].subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ubuntu-public-ip.id

  }
}

#### VM 

resource "azurerm_linux_virtual_machine" "azure-spoke-vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.aviatrix-rg.name
  location            = azurerm_resource_group.aviatrix-rg.location
  size                = "Standard_B1s"
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.iface.id,
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

####################################################################
# Azure Ubuntu Instance
################################################################


#### Public IP 

resource "azurerm_public_ip" "windows-public-ip" {
  name                = "public-ip-${var.vm_name}"
  location            = azurerm_resource_group.aviatrix-rg.location
  resource_group_name = azurerm_resource_group.aviatrix-rg.name
  allocation_method   = "Dynamic"
 }

#### VM interface 

resource "azurerm_network_interface" "win-iface" {
  name                = "nic-windows-${var.vm_name}"
  location            = azurerm_resource_group.aviatrix-rg.location
  resource_group_name = azurerm_resource_group.aviatrix-rg.name

  ip_configuration {
    name                          = "windows-${var.vm_name}"
    subnet_id = aviatrix_vpc.aviatrix_vpc_vnet.subnets[1].subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.windows-public-ip.id

  }
}

#### VM 

resource "azurerm_windows_virtual_machine" "azure-spoke-vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.aviatrix-rg.name
  location            = azurerm_resource_group.aviatrix-rg.location
  size                = "Standard_B1s"
  admin_username      = "aviatrix"
  network_interface_ids = [
    azurerm_network_interface.iface.id,
  ]

  admin_password = "Aviatrix123#"
  disable_password_authentication = "false"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference { 
    publisher="MicrosoftWindowsDesktop"
    offer="Windows-10"
    sku="20h1-pro"
    version="latest"
  }
}

output "public_ip_address_windows" {
  value = azurerm_public_ip.windows-public-ip.ip_address
}



output "public_ip_address_ubuntu" {
  value = azurerm_public_ip.ubuntu-public-ip.ip_address
}

# resource "aws_route53_record" "azure_vm_fqdn" {
#   count = (var.cloud_type == "azure") ? 1 : 0
#   zone_id    = data.aws_route53_zone.pub.zone_id
#   name       = "${var.vm_name}.mcna.cc"
#   type       = "A"
#   ttl        = "300"
#   records    = [azurerm_public_ip.avtx-public-ip[0].ip_address]
# }
