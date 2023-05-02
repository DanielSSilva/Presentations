variable "customer_name" {
  description = "The name of the project that will use the storage accounts."
  type = string
}

variable "storage_account_config" {
  description = "The types of storage account, for demo purpose."
  type = list(object({
    suffix = string
    network_rules_default_action = string
    network_rules_ip_rules = list(string)
    # container_names = list(string)
  }))
}

variable "container_name" {
  description = "The name of the container in the storage account. All storage accounts will have a container with this name"
  type = string
}
