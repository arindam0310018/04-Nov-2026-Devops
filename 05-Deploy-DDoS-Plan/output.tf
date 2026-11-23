##################
# Output Block:-
##################

output "ddos_plan_name" {
  value = azurerm_network_ddos_protection_plan.ddos-plan.name
}

output "ddos_plan_id" {
  value = azurerm_network_ddos_protection_plan.ddos-plan.id
}
