terraform {

  required_version = ">= 1.3.3"
  
  backend "azurerm" {
    resource_group_name  = "BIL-S_T_TEST_Storage"
    storage_account_name = "bilstesttfstate"
    container_name       = "tfstate"
    key                  = "MS-Defender-Plans/enabledefenderplans.tfstate"
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.61"
    }
  }
}

provider "azurerm" {
  features {}
}

