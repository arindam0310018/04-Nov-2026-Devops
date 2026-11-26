###############################
# Azure Managed Data Disk(s):-
###############################

resource "azurerm_managed_disk" "vm-data-disk" {
  name = "${var.vm_name}-datadisk-01"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  storage_account_type = "Premium_LRS"
  create_option = "Empty"
  disk_size_gb = 512
  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm-data-disk-attach" {
  managed_disk_id = azurerm_managed_disk.vm-data-disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun = 0
  caching = "ReadOnly"
}
