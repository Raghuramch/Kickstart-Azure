# Azure backend module

Reusable Terraform child module that creates the Azure resources used by an `azurerm` backend:

- Resource group
- StorageV2 account with blob versioning and seven-day deletion retention
- Private blob container

The module does not configure a provider or declare a Terraform backend. The calling root module owns both settings.

## Usage

```hcl
module "terraform_backend" {
  source = "./modules/azure-backend"

  subscription_id      = "00000000-0000-0000-0000-000000000000"
  location             = "eastus"
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "tfstateunique123456"
  container_name       = "tfstate"
  state_key            = "application.tfstate"
}
```

After applying the bootstrap root, save the `backend_config_hcl` output to a file:

```bash
terraform output -raw backend_config_hcl > backend.hcl
```

Use it to initialize the Terraform root that needs remote state:

```bash
terraform init -backend-config=/absolute/path/to/backend.hcl
```

The backend output enables Microsoft Entra authentication. The identity running the consuming Terraform root needs a data-plane role such as **Storage Blob Data Contributor** on the storage account or container.
