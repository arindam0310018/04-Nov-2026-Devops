##################
# Resource Block:-
##################

resource "azurerm_network_ddos_protection_plan" "ddos-plan" {
  name                = var.ddos_plan_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}