################################################
# Network Security Group
# Network Security Group Rules
# Network Security Group attachment to VM NIC
################################################

resource "azurerm_network_security_group" "nsg" {
  name = "${var.vm_name}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  tags = var.tags

  security_rule {
    name = "Allow-RDP-From-Authorized-Subnet"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = var.rdp_source_cidr
    destination_address_prefix = "*"
  }
  security_rule {
    name = "Allow-All-From-VirtualNetwork"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "Deny-All-Other-Inbound"
    priority = 4096
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id = azurerm_network_interface.vm-nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
