# Azure VM tag project

This project creates a resource group, virtual network, subnet, network interfaces, and Ubuntu Linux VMs. Each VM uses the SSH public key and tags in `terraform.tfvars.json`. VMs have private IP addresses only; no inbound access is opened. Azure resources, including the Terraform state storage account, may incur charges.

## One-time GitHub and Azure setup

1. Put the extracted project files in the **root** of a GitHub repository, including the `.github` folder. You can add them through the GitHub website.
2. Create an Azure app registration or user-assigned managed identity for GitHub Actions. Grant it **Contributor** on the target subscription. The workflows need this to create resources and the separate Terraform state storage account.
3. Add a federated credential to that identity for your GitHub repository's **default branch**. Its subject is `repo:OWNER/REPO:ref:refs/heads/BRANCH`, replacing `OWNER`, `REPO`, and `BRANCH` with your values. The issuer is `https://token.actions.githubusercontent.com` and the audience is `api://AzureADTokenExchange`.
4. In GitHub repository **Settings → Secrets and variables → Actions**, add repository secrets `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`. The subscription secret must match `subscription_id` in `terraform.tfvars.json`.

No Azure client secret or local Terraform installation is needed. The public SSH key in `terraform.tfvars.json` is safe to commit; keep its matching **private** key outside the repository.

## Run in GitHub Actions

Open the repository's **Actions** tab and use **Run workflow** on the default branch:

1. Run **Terraform plan** to review the proposed Azure resources in the job log.
2. Run **Terraform apply** to create them. This workflow runs a fresh plan and applies it from the default branch only.
3. Run **Export VM tags to Excel** after deployment. Download `azure-vm-tags` from the workflow's **Artifacts** section. It contains `azure_vm_tags.xlsx`.

The first plan or apply run creates a separate `rg-terraform-state` resource group and a private Azure Storage account for remote Terraform state. Later runs reuse it. Keep this state storage account and its container; Terraform needs them to track the VMs.

The workbook's **VMs** sheet contains key VM information and one column per tag. **Tags** lists every tag separately. **All Details** contains every field returned by `az vm show --show-details`, flattened into paths.
