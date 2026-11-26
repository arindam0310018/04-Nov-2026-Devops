####################
# All Variables:-
####################

#######################################################
# Subscription, Resource Group Name and Location :-
#######################################################

variable "subscription_id" {
   description = "Subscription ID where the Key Vault and Private Endpoint will be created."
   type = string 
  }

variable "resource_group_name" { 
  type = string 
  }

variable "location" { 
  description = "Azure region."
  type = string
  default = "switzerlandnorth" 
  }

################
# Network :-
################

variable "vnet_resource_group_name" { 
  type = string 
  }

variable "vnet_name" { 
  type = string 
  }

variable "subnet_name" { 
  type = string 
  }


##############
# VM:-
##############


variable "vm_name" { 
  type = string  
  }

variable "vm_size" { 
  type = string 
  default = "Standard_D2s_v5"
  }

variable "admin_username" { 
  type = string 
  default = "azureadmin" 
  }


########
# NSG:-
########

variable "rdp_source_cidr" { 
  type = string 
  }


##################
# Key Vault :-
##################

variable "kv_private_dns_resource_group_name" {
  description = "Resource group containing the existing Key Vault Private DNS zone"
  type        = string
}

variable "key_vault_sku" {
  description = "Key Vault SKU."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "key_vault_sku must be standard or premium."
  }
}

variable "kv_private_dns_zone_id" {
  description = "Resource ID of the existing privatelink.vaultcore.azure.net Private DNS zone."
  type        = string
}

variable "kv_rbac_role_definition_name" {
  description = "Key Vault RBAC role assigned to rbac_principal_id."
  type        = string
  default     = "Key Vault Secrets Officer"
}

variable "kv_rbac_principal_ids" {
  description = "Object IDs to assign RBAC access to the Key Vault."
  type        = set(string)
  default     = []
}

variable "kv_soft_delete_retention_days" {
  description = "Number of days to retain a soft-deleted Key Vault."
  type        = number
  default     = 90

  validation {
    condition = (
      var.kv_soft_delete_retention_days >= 7 &&
      var.kv_soft_delete_retention_days <= 90
    )
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

###############
# Tags :-
###############

variable "tags" {
  type = map(string)
  default = { 
    Business-Unit         = "IT"
    Data-Classification   = "General"
    Environment           = "Production" 
    Managed-By            = "Terraform"
    Onwer                 = "Arindam Mitra" 
    Workload              = "Windows-Server" 
    }
}




