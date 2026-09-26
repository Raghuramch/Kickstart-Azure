variable "subscription_id" {
  description = "Azure subscription in which the Terraform backend will be created."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a valid UUID."
  }
}

variable "location" {
  description = "Azure region for the backend resources."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group that holds the Terraform backend."
  type        = string
  default     = "rg-terraform-state"
}

variable "storage_account_name" {
  description = "Globally unique storage account name, using 3-24 lowercase letters and numbers."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must contain 3-24 lowercase letters and numbers only."
  }
}

variable "container_name" {
  description = "Blob container used for Terraform state."
  type        = string
  default     = "tfstate"

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])$", var.container_name)) && !strcontains(var.container_name, "--")
    error_message = "container_name must contain 3-63 lowercase letters, numbers, or single hyphens."
  }
}

variable "state_key" {
  description = "Blob name used by a Terraform root module for its state."
  type        = string
  default     = "terraform.tfstate"

  validation {
    condition     = length(trimspace(var.state_key)) > 0
    error_message = "state_key cannot be empty."
  }
}

variable "tags" {
  description = "Tags assigned to the backend resource group and storage account."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Purpose   = "Terraform state"
  }
}
