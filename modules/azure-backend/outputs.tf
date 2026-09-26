output "resource_group_name" {
  description = "Backend resource group name."
  value       = azurerm_resource_group.backend.name
}

output "storage_account_name" {
  description = "Backend storage account name."
  value       = azurerm_storage_account.backend.name
}

output "storage_account_id" {
  description = "Resource ID of the backend storage account."
  value       = azurerm_storage_account.backend.id
}

output "container_name" {
  description = "Backend state container name."
  value       = azurerm_storage_container.backend.name
}

output "backend_config_hcl" {
  description = "Backend configuration for terraform init -backend-config=backend.hcl."
  value       = <<-EOT
    resource_group_name  = "${azurerm_resource_group.backend.name}"
    storage_account_name = "${azurerm_storage_account.backend.name}"
    container_name       = "${azurerm_storage_container.backend.name}"
    key                  = "${var.state_key}"
    subscription_id      = "${var.subscription_id}"
    use_azuread_auth     = true
  EOT
}
