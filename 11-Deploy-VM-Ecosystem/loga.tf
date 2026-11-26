############################
# Log Analytics Workspace :-
############################

resource "azurerm_log_analytics_workspace" "loga" {
  name                      = "${var.vm_name}-loga"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location

  sku                       = "PerGB2018"
  retention_in_days         = 30

  tags = var.tags
}