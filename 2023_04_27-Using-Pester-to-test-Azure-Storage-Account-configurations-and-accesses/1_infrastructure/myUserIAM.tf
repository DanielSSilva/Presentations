locals {
  my_user_object_id = "2d2ba136-730d-4502-a27a-916362b206a6"
}

resource "azurerm_key_vault_access_policy" "myUser" {
  key_vault_id  = azurerm_key_vault.terraform.id
  tenant_id     = data.azuread_client_config.current.tenant_id
  object_id     = local.my_user_object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge"
  ]
}

resource "azurerm_role_assignment" "myUser" {
  depends_on                        = [azuread_application.terraform]
  scope                             = azurerm_resource_group.terraform.id
  role_definition_name              = "Contributor"
  principal_id                      = local.my_user_object_id
}
