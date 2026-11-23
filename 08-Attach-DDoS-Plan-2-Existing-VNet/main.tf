terraform {

  required_version = ">= 1.5.0"
  
  backend "azurerm" {
    resource_group_name     = "AM_T_TEST_Storage"
    storage_account_name    = "amtesttfstate"
    container_name          = "tfstate"
    key                     = "Attach-DDoS-Plan/attach-ddos-2-test-vnets.tfstate"
    use_azuread_auth        = true
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=4.0"
    }

    azapi = {
      source = "Azure/azapi"
      version = "~> 2.0"
    }

  }
}

#####################################################
# Default Provider:
# TEST Subscription containing the Existing VNets.
#####################################################

provider "azurerm" {

  features {}

  subscription_id = var.test_subscription_id
}

#####################################################
# PROD provider:
# PROD Subscription containing the Existing DDoS plan.
#####################################################

provider "azurerm" {
  
  features {}

  alias = "prod"

  subscription_id = var.prod_subscription_id
}

#####################################################

provider "azapi" {

subscription_id = var.test_subscription_id

}

#####################################################
