###############################
# Data Block :-
# 1. Virtual Network
# 2. Subnet
# 3. Key Vault Private DNS 
###############################

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "vnet" {
  name                      = var.vnet_name
  resource_group_name       = var.vnet_resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                      = var.subnet_name
  virtual_network_name      = data.azurerm_virtual_network.vnet.name
  resource_group_name       = var.vnet_resource_group_name
}

data "azurerm_private_dns_zone" "kv-pe-dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.kv_private_dns_resource_group_name
}
