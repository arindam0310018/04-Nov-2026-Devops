terraform {

  required_version = ">= 1.5.0"
  
  backend "azurerm" {
    resource_group_name  = "AM_Production_Storage"
    storage_account_name = "amprodtfstate"
    container_name       = "tfstate"
    key                  = "DDoS-Plan/ddos.tfstate"

    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
