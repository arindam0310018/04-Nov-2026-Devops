###############################
# Azure Key Vaults:-
###############################

resource "azurerm_key_vault" "kv" {
  name                = "${var.vm_name}-kv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = var.key_vault_sku

# Use Azure RBAC instead of legacy Key Vault access policies
  rbac_authorization_enabled = true

  # Private access only
  public_network_access_enabled = true

  # Security configuration
  soft_delete_retention_days = var.kv_soft_delete_retention_days
  purge_protection_enabled   = true

  # Prevent deployments from bypassing the network restriction
  network_acls {
    bypass         = "None"
    default_action = "Deny"
    ip_rules = [
      "XXX.XXX.XXX.XXX/32"
    ]
  }

  tags = var.tags
}

#######################################
# Azure Key Vault Private Endpoint:-
#######################################

resource "azurerm_private_endpoint" "kv-pe" {
  name                = "${var.vm_name}-kv-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${var.vm_name}-kv-pe-conn"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  # Consume the existing Key Vault Private DNS zone
  private_dns_zone_group {
    name                 = "keyvault-private-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.kv-pe-dns.id]
  }

  tags = var.tags
}

#######################################
# Azure Key Vault RBAC:-
#######################################

resource "azurerm_role_assignment" "kv-rbac" {
  for_each              = var.kv_rbac_principal_ids

  scope                 = azurerm_key_vault.kv.id
  role_definition_name  = var.kv_rbac_role_definition_name
  principal_id          = each.value
}

###############################################################
# Generate Password Automatically for Azure VM Admin Login:-
###############################################################

resource "random_password" "random-passwd" {
  length = 24
  special = true
  override_special = "!@#$%*-_"
}

################################################################################################
# Password Automatically Generated for Azure VM Admin Login is Stored in Key Vault as Secret:-
################################################################################################

resource "azurerm_key_vault_secret" "vm-admin-random-passwd" {
  name = "${var.vm_name}-admin-password"
  value = random_password.random-passwd.result
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "IT Service Desk VM Admin Password"
}

#######################################
# Azure Key Vault Diagnistic Settings:-
#######################################

resource "azurerm_monitor_diagnostic_setting" "kv-diag" {
  name                       = "${var.vm_name}-kv-diag"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.loga.id

  enabled_metric {
    category = "AllMetrics"
  }
}
