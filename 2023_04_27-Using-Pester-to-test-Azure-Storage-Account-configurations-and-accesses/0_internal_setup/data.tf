data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {} 


data "azurerm_resource_group" "terraform" {
  name = "rg-pssummit"
}