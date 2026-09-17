#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
if [[ "$mode" != "plan" && "$mode" != "apply" ]]; then
  echo "Usage: terraform-ci.sh plan|apply" >&2
  exit 2
fi

location="$(python3 -c 'import json; print(json.load(open("terraform.tfvars.json"))["location"])')"
configured_subscription="$(python3 -c 'import json; print(json.load(open("terraform.tfvars.json"))["subscription_id"])')"
actual_subscription="$(az account show --query id --output tsv)"
if [[ "$actual_subscription" != "$configured_subscription" ]]; then
  echo "Azure login subscription does not match terraform.tfvars.json." >&2
  exit 1
fi

# The state account is separate from Terraform-managed resources so init can run first.
state_group="rg-terraform-state"
state_account="tf$(printf '%s' "$GITHUB_REPOSITORY-$actual_subscription" | sha256sum | cut -c1-22)"
az group create --name "$state_group" --location "$location" --output none
if ! az storage account show --name "$state_account" --resource-group "$state_group" --output none 2>/dev/null; then
  az storage account create \
    --name "$state_account" \
    --resource-group "$state_group" \
    --location "$location" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access false \
    --output none
fi

state_key="$(az storage account keys list --account-name "$state_account" --resource-group "$state_group" --query '[0].value' --output tsv)"
echo "::add-mask::$state_key"
az storage container create --name tfstate --account-name "$state_account" --account-key "$state_key" --output none
export ARM_ACCESS_KEY="$state_key"

terraform init -input=false \
  -backend-config="resource_group_name=$state_group" \
  -backend-config="storage_account_name=$state_account" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=azure-vms.tfstate"
terraform fmt -check -recursive
terraform validate

if [[ "$mode" == "plan" ]]; then
  terraform plan -input=false -no-color
else
  terraform plan -input=false -out=apply.tfplan
  terraform apply -input=false -auto-approve apply.tfplan
fi
