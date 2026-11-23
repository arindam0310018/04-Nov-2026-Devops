##################
# Resource Block:-
##################

resource "azapi_update_resource" "attach_ddos_2_test_vnets" {
  for_each              = data.azurerm_virtual_network.test_vnets

  type                  = "Microsoft.Network/virtualNetworks@2024-05-01"
  resource_id           = each.value.id

  body                  = {
                            properties = {
                                enableDdosProtection = true
                                ddosProtectionPlan = {
                                  id = data.azurerm_network_ddos_protection_plan.prod_ddos_plan.id
                                }
                            }
                          }
}