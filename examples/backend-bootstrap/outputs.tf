output "backend_config_hcl" {
  description = "Configuration for terraform init -backend-config=backend.hcl."
  value       = module.terraform_backend.backend_config_hcl
}

output "storage_account_id" {
  description = "Resource ID of the backend storage account."
  value       = module.terraform_backend.storage_account_id
}
