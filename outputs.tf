output "resource_group_name" {
  value = azurerm_resource_group.vm.name
}

output "vm_ids" {
  value = { for name, vm in azurerm_linux_virtual_machine.vm : name => vm.id }
}

output "private_ip_addresses" {
  value = { for name, nic in azurerm_network_interface.vm : name => nic.private_ip_address }
}
