resource "azurerm_storage_account" "terraform" {
  for_each                          = { for x in var.storage_account_config: x.suffix => x }
  name                              = "st${var.customer_name}${each.key}${terraform.workspace}"
  resource_group_name               = azurerm_resource_group.terraform.name
  location                          = azurerm_resource_group.terraform.location
  account_replication_type          = "LRS"
  account_tier                      = "Standard"
  allow_nested_items_to_be_public   = false

   network_rules {
    default_action = each.value.network_rules_default_action
    # We need to add the current runner's IP in cases where default action is deny
    # so that terraform can successfully check/perform actions on this resource
    # This means that we need to then remove this IP afterwards.
    # This can be read as: If action is deny, concat defined IPs with current IP. Otherwise, since the action is allow, set ip_rules as empty.
    # NOTE: This is required for the first execution
    ip_rules = each.value.network_rules_default_action == "Deny" ? concat(each.value.network_rules_ip_rules, [data.http.currentIP.response_body]) : []
    
  }
}

data "azurerm_storage_account_sas" "terraform" {
  for_each = azurerm_storage_account.terraform
  connection_string = azurerm_storage_account.terraform[each.key].primary_connection_string
  https_only        = true
  start  = "2022-10-01T00:00:00Z"
  expiry = "2023-12-31T00:00:00Z"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

resource "azurerm_storage_container" "storage-container" {
  for_each              = azurerm_storage_account.terraform
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.terraform[each.key].name
  container_access_type = "private"
}
