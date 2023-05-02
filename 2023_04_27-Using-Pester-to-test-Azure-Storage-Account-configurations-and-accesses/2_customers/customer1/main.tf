module "storageaccount" {
    source = "./../../1_infrastructure"
    storage_account_config = var.storage_account_config
    customer_name = "customer1"
    container_name = var.container_name
}