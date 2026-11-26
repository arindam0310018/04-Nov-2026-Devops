############################
# Terraform Versions
# Provider Versions
# Backend Tfstate Configuration
############################

terraform {

  required_version = ">= 1.5.0"
  
  backend "azurerm" {
    resource_group_name  = "[NAME OF THE RESOURCE GROUP]"
    storage_account_name = "[NAME OF THE STORAGE ACCOUNT]"
    container_name       = "[NAME OF THE STORAGE ACCOUNT CONTAINER NAME]"
    key                  = "Infra/infra.tfstate"

    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=4.0"
    }

    random  = { 
      source = "hashicorp/random"
      version = "~> 3.0" 
    }

  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}