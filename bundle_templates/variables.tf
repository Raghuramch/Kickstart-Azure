variable "subscription_id" {
  description = "Azure subscription where the resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the new resource group."
  type        = string
}

variable "location" {
  description = "Azure region, for example eastus."
  type        = string
}

variable "vm_names" {
  description = "Names of the Linux VMs to create."
  type        = list(string)
}

variable "vm_size" {
  description = "Azure VM SKU."
  type        = string
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for VM access."
  type        = string
}

variable "tags" {
  description = "Tags applied to the resource group, virtual network, NICs, and VMs."
  type        = map(string)
  default     = {}
}
