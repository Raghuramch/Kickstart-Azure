module "terraform_backend" {
  source = "../../modules/azure-backend"

  subscription_id      = var.subscription_id
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_name = var.storage_account_name
  container_name       = var.container_name
  state_key            = var.state_key
  tags                 = var.tags
}
