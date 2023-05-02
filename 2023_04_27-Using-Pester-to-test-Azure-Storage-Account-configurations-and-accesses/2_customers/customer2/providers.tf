terraform {
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
    resource_group_name   = "rg-pssummit"
    storage_account_name  = "stpssummittfstate"
    container_name        = "terraform"
    key                   = "customer2.tfstate"
    subscription_id       = "xxxxxx-xxxx-xxxx-xxxx-xxxxxx"
    tenant_id             = "xxxxxx-xxxx-xxxx-xxxx-xxxxxx"
  }
}

provider "azurerm" {
  features {}
}
