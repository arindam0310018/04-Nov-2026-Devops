##################
# Output Block:-
##################

output "ddos_plan_id" {
  description = "Resource ID of the existing PROD DDoS protection plan."
  value       = data.azurerm_network_ddos_protection_plan.prod_ddos_plan.id
}

output "ddos_plan_name" {
  description = "Name of the existing PROD DDoS protection plan."
  value       = data.azurerm_network_ddos_protection_plan.prod_ddos_plan.name
}

output "protected_test_vnets" {
  description = "TEST virtual networks associated with the PROD DDoS protection plan."

  value = {
    for vnet_name, attachment in azapi_update_resource.attach_ddos_2_test_vnets :
    vnet_name => {
      vnet_id      = attachment.resource_id
      ddos_plan_id = data.azurerm_network_ddos_protection_plan.prod_ddos_plan.id
      enabled      = true
    }
  }
}