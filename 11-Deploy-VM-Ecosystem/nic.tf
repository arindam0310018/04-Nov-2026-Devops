############################
# Azure VM NIC:-
############################

resource "azurerm_network_interface" "vm-nic" {
  name = "${var.vm_name}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  tags = var.tags
  ip_configuration {
    name = "internal"
    subnet_id = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
