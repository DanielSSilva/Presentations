terraform {
  required_version = ">=1.3.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.12.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.30.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-pssummit"
    storage_account_name = "stpssummittfstate"
    container_name       = "terraform"
    key                  = "internal.tfstate"
  }
}

provider "azurerm" {
  features {}
  
}
