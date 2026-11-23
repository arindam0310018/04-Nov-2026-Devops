##################
# Data Block:-
##################

data "azurerm_network_ddos_protection_plan" "prod_ddos_plan" {
  provider              = azurerm.prod
  name                  = var.ddos_plan_name
  resource_group_name   = var.prod_resource_group_name
}


data "azurerm_virtual_network" "test_vnets" {
  for_each              = var.test_vnet_names
  name                  = each.value
  resource_group_name   = var.test_resource_group_name
}