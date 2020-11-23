########## Providers ####

provider "aviatrix" {
  username     = "admin"
  password      = var.ctrl_password
  controller_ip = "18.156.141.82"
  version       = "2.17.0"
}


provider "aws" {
  version    = "~> 2.0"
  region = (var.cloud_type == "aws") ? var.cloud_region["${var.aviatrix_transit_gateway}"]  : "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_application_id
  client_secret   = var.azure_application_key
  tenant_id       = var.azure_directory_id
  version = "=2.0.0"
}
