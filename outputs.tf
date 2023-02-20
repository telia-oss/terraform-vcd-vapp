output "vapps" {
  value       = vcd_vapp.this
  description = "The vcd_vapp resources created by this module"
}

output "vms" {
  value       = vcd_vapp_vm.this
  description = "Name-indexed list of VM resources created in this module"
}

output "networks" {
  value       = vcd_vapp_org_network.this
  description = "Name-indexed list of vcd_vapp_org_network resources that were attached to this vApp"
}
