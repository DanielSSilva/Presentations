resource "azurerm_resource_group" "terraform" {
  name = "rg-${var.customer_name}-${terraform.workspace}"
  location = "West Europe"
}

# assign the customer's service principal to the storage account as data contributor
resource "azurerm_role_assignment" "sp-storage" {
  depends_on                        = [azuread_application.terraform]
  for_each                          = azurerm_storage_account.terraform
  scope                             = azurerm_storage_account.terraform[each.key].id
  role_definition_name              = "Storage Blob Data Contributor"
  principal_id                      = azuread_service_principal.app_service_principal.object_id
  skip_service_principal_aad_check  = true
}

resource "azurerm_role_assignment" "sp-resourcegroup" {
  depends_on                        = [azuread_application.terraform]
  scope                             = azurerm_resource_group.terraform.id
  role_definition_name              = "Contributor"
  principal_id                      = azuread_service_principal.app_service_principal.object_id
  skip_service_principal_aad_check  = true
}
