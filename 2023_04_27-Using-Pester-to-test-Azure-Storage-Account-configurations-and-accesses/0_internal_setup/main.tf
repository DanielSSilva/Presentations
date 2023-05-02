

resource "random_string" "resource_code" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_key_vault" "terraform" {
  name                          = "kv-powershellsummit-${random_string.resource_code.result}"
  location                      = data.azurerm_resource_group.terraform.location
  resource_group_name           = data.azurerm_resource_group.terraform.name
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  sku_name                      = "standard"
}

resource "azurerm_key_vault_access_policy" "sp-policy" {
  depends_on = [
    azurerm_key_vault.terraform
  ]
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

resource "azurerm_key_vault_access_policy" "myuser" {
  depends_on = [
    azurerm_key_vault.terraform
  ]
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
  depends_on = [azurerm_key_vault_access_policy.sp-policy, azurerm_key_vault_access_policy.myuser]
  name         = "app-secret-provisioner"
  value        = azuread_application_password.terraform.value
  key_vault_id = azurerm_key_vault.terraform.id
}

resource "azurerm_storage_account" "demo" {
  name                              = "stpssummitdemo${random_string.resource_code.result}"
  resource_group_name               = data.azurerm_resource_group.terraform.name
  location                          = data.azurerm_resource_group.terraform.location
  account_replication_type          = "LRS"
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false
  network_rules {
    default_action = "Deny"
    ip_rules = []
  }
}

resource "azurerm_storage_container" "storage-container" {
  name                  = "demo"
  storage_account_name  = azurerm_storage_account.demo.name
  container_access_type = "private"
}