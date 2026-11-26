##################################
# Virtual Machine Deploymment :-
##################################

resource "azurerm_windows_virtual_machine" "vm" {
  name                              = "${var.vm_name}-vm"
  computer_name                     = "AzServiceDesk"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = azurerm_resource_group.rg.location
  size                              = var.vm_size
  admin_username                    = var.admin_username
  admin_password                    = azurerm_key_vault_secret.vm-admin-random-passwd.value
  #admin_password                    = output.admin_password_secret_value.value
  network_interface_ids             = [azurerm_network_interface.vm-nic.id]
  encryption_at_host_enabled        = true
  provision_vm_agent                = true
  tags                              = var.tags
  os_disk {
    name                            = "${var.vm_name}-osdisk"
    caching                         = "ReadWrite"
    storage_account_type            = "Premium_LRS"
  }
  source_image_reference {
    publisher                       = "MicrosoftWindowsServer"
    offer                           = "WindowsServer"
    sku                             = "2022-datacenter-azure-edition"
    version                         = "latest"
  }
  depends_on                        = [azurerm_network_interface_security_group_association.nsg-association]
}
