#####################################################################
# Recovery Services Vault and Azure Backup policy.
# Azure Backup is Microsoft-managed; no backup server is deployed.
#####################################################################

resource "azurerm_recovery_services_vault" "rsv" {
  name                          = "${var.vm_name}-rsv"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = "Standard"
  storage_mode_type             = "GeoRedundant"
  tags                          = var.tags
}

resource "azurerm_backup_policy_vm" "rsv-backup-policy" {
  name                          = "${var.vm_name}-rsv-backup-policy"
  resource_group_name           = azurerm_resource_group.rg.name
  recovery_vault_name           = azurerm_recovery_services_vault.rsv.name
  policy_type                   = "V2"
  timezone                      = "UTC"
  backup {
    frequency = "Hourly"
    hour_interval = 4
    hour_duration = 24
    time = "00:00"
  }
  retention_daily { count = 30 }
  retention_monthly {
    count = 3
    weekdays = ["Sunday"]
    weeks = ["First"]
  }
  instant_restore_retention_days = 7
}


resource "azurerm_backup_protected_vm" "backup-protected-vm" {
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  source_vm_id = azurerm_windows_virtual_machine.vm.id
  backup_policy_id = azurerm_backup_policy_vm.rsv-backup-policy.id
  depends_on = [azurerm_virtual_machine_data_disk_attachment.vm-data-disk-attach]
}
