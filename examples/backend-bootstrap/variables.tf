variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type    = string
  default = "rg-terraform-state"
}

variable "storage_account_name" {
  type = string
}

variable "container_name" {
  type    = string
  default = "tfstate"
}

variable "state_key" {
  type    = string
  default = "terraform.tfstate"
}

variable "tags" {
  type = map(string)
  default = {
    ManagedBy = "Terraform"
    Purpose   = "Terraform state"
  }
}
