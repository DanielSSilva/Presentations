data "http" "currentIP" {
  url = "https://api.ipify.org"
}

data "azurerm_client_config" "current" {}

data "azuread_client_config" "current" {} 

# data "azurerm_resource_group" "terraform" {
#   name = var.resource_group_name
# }
