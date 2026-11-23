
##########################
# Foundational CSPM:-
##########################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-cspm

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/CloudPosture"
}

#############################
# Defender for Servers:-
#############################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-servers

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/VirtualMachines"
}

#################################################
# Defender for App Services
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-appservice-api[0]

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/AppServices"
}

#################################################
# Defender for SQL Servers
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-db[0]

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/SqlServers"
}

#################################################
# Defender for OSS Databases
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-db[1]

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/OpenSourceRelationalDatabases"
}

#################################################
# Defender for SQL on Machines
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-db[2]

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/SqlServerVirtualMachines"
}

#################################################
# Defender for Cosmos DB
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-db[3]

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/CosmosDbs"
}

#################################################
# Defender for Storage
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-storage

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/StorageAccounts"
}

#################################################
# Defender for Containers
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-containers

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/Containers"
}

#################################################
# Defender for Key Vault
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-kv

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/KeyVaults"
}

#################################################
# Defender for ARM
#################################################

import {
  to = azurerm_security_center_subscription_pricing.az-mdc-arm

  id = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/providers/Microsoft.Security/pricings/Arm"
}

# #################################################
# # Discovery
# #################################################

# import {
#   to = azurerm_security_center_subscription_pricing.az_mdc_discovery

#   id = "/subscriptions/a3390541-963c-4b3a-85d3-66c263f33b39/providers/Microsoft.Security/pricings/Discovery"
# }

