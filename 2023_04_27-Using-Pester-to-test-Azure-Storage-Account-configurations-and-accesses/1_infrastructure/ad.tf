resource "azuread_application" "terraform" {
  display_name     = "app-${var.customer_name}-${terraform.workspace}"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "app_service_principal" {
  application_id               = azuread_application.terraform.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "terraform" {
  application_object_id = azuread_application.terraform.object_id
}

