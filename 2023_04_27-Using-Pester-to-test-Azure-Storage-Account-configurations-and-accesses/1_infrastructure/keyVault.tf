
resource "azurerm_key_vault" "terraform" {
  name                          = "kv-${var.customer_name}-${terraform.workspace}"
  location                      = azurerm_resource_group.terraform.location
  resource_group_name           = azurerm_resource_group.terraform.name
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  sku_name                      = "standard"
}

resource "azurerm_key_vault_access_policy" "sp-policy" {
  key_vault_id  = azurerm_key_vault.terraform.id
  tenant_id     = data.azuread_client_config.current.tenant_id
  object_id     = azuread_service_principal.app_service_principal.object_id

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

resource "azurerm_key_vault_access_policy" "provisioner" {
  key_vault_id  = azurerm_key_vault.terraform.id
  tenant_id     = data.azuread_client_config.current.tenant_id
  object_id     = data.azuread_client_config.current.object_id

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

resource "azurerm_key_vault_secret" "spscret" {
  depends_on = [azurerm_key_vault_access_policy.sp-policy, azurerm_key_vault_access_policy.provisioner]
  name         = "${azuread_application.terraform.display_name}-secret"
  value        = azuread_application_password.terraform.value
  key_vault_id = azurerm_key_vault.terraform.id
}

resource "azurerm_key_vault_secret" "sas-token-storageaccount" {
  depends_on    = [azurerm_key_vault_access_policy.sp-policy, azurerm_key_vault_access_policy.provisioner]
  for_each      = data.azurerm_storage_account_sas.terraform
  name          = "sas-token-sa-${azurerm_storage_account.terraform[each.key].name}"
  value         = data.azurerm_storage_account_sas.terraform[each.key].sas
  key_vault_id  = azurerm_key_vault.terraform.id
}
