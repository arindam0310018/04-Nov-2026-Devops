#############################
# Outputs:-
#############################

#############################
# Resource Group Outputs:-
#############################

output "resource_group_name" { 
    value = azurerm_resource_group.rg.name 
    }

#############################
# Virtual Machine Outputs:-
#############################

output "vm_id" { 
    value = azurerm_windows_virtual_machine.vm.id 
    }

output "encryption_at_host_enabled" { 
    value = azurerm_windows_virtual_machine.vm.encryption_at_host_enabled 
    }

output "data_disk_id" { 
    value = azurerm_managed_disk.vm-data-disk.id
    }

output "vm_private_ip" { 
    value = azurerm_network_interface.vm-nic.private_ip_address 
    }

output "nsg_id" { 
    value = azurerm_network_security_group.nsg.id 
    }

##############################
# Key Vault Outputs:-
##############################

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

##########################################
# Key Vault Private Endpoint Outputs:-
##########################################

output "key_vault_private_endpoint_id" {
  description = "Resource ID of the Key Vault Private Endpoint"
  value       = azurerm_private_endpoint.kv-pe.id
}

output "key_vault_private_ip" {
  description = "Private IP address of the Key Vault Private Endpoint"
  value = try(
    azurerm_private_endpoint.kv-pe.private_service_connection[0].private_ip_address,
    null
  )
}

###############################
# Key Vault Secret Outputs:-
###############################

output "admin_password_secret_name" { 
    value = azurerm_key_vault_secret.vm-admin-random-passwd.name 
    }

output "admin_password_secret_id" { 
    value = azurerm_key_vault_secret.vm-admin-random-passwd.id 
    }

output "admin_password_secret_value" { 
    value = azurerm_key_vault_secret.vm-admin-random-passwd.value 
    sensitive = true
    }

###############################
# Log Analytics Outputs:-
###############################

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.loga.name
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.loga.id
}

######################################
# Recovery Services Vault Outputs:-
######################################

output "recovery_services_vault_name" { 
    value = azurerm_recovery_services_vault.rsv.name 
    }

output "recovery_services_vault_id" { 
    value = azurerm_recovery_services_vault.rsv.id 
    }

output "backup_policy_name" { 
    value = azurerm_backup_policy_vm.rsv-backup-policy.name 
    }

output "backup_policy_id" { 
    value = azurerm_backup_policy_vm.rsv-backup-policy.id 
    }
