# Backend bootstrap example

This example is a disposable root module that calls the reusable Azure backend module. It intentionally starts with local state because the remote backend does not exist yet.

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your subscription and a globally unique storage name.
az login
terraform init
terraform apply
terraform output -raw backend_config_hcl > backend.hcl
```

Use `backend.hcl` when initializing the separate Terraform root that will store its state remotely.
