resource "vcd_vapp" "this" {
  for_each = toset(
    compact(
      [for vm_name, vm in var.vms : coalesce(vm["vapp_name"], var.vapp_name, vm_name)]
    )
  )
  org      = var.org_name
  vdc      = var.vdc_name
  name     = each.key
  metadata = var.metadata
}

resource "vcd_vapp_org_network" "this" {
  for_each = merge(
    [
      for vm_name, vm in var.vms :
      {
        for network in keys(vm["networks"]) :
        "${coalesce(vm["vapp_name"], var.vapp_name, vm_name)}-${network}" => {
        vapp = vcd_vapp.this[coalesce(vm["vapp_name"], var.vapp_name, vm_name)]
        network_name = network
      } if vm["networks"] != null
      }
    ]...
  )
  vdc              = var.vdc_name
  vapp_name        = each.value.vapp.name
  org_network_name = each.value.network_name
}

resource "vcd_vm_internal_disk" "this" {
  for_each = merge(
    [
      for name, vm_iter in var.vms :
      {
        for i, disk in concat(var.internal_disks, vm_iter["internal_disks"]) :
        "${name}-${i}" => merge(
        disk,
        {
          vm = vcd_vapp_vm.this[name],
          vapp = vcd_vapp.this[coalesce(vm_iter["vapp_name"], var.vapp_name, name)]
        }
      )
      } if vm_iter["internal_disks"] != null
    ]...
  )
  vdc             = var.vdc_name
  vapp_name       = each.value["vapp"].name
  vm_name         = each.value["vm"].name
  allow_vm_reboot = try(each.value["allow_vm_reboot"], null)
  bus_type        = each.value["bus_type"]
  size_in_mb      = each.value["size_in_mb"]
  bus_number      = each.value["bus_number"]
  unit_number     = each.value["unit_number"]
  iops            = try(each.value["iops"], null)
  storage_profile = try(each.value["storage_profile"], null)
}

resource "vcd_vapp_vm" "this" {
  for_each      = var.vms
  org           = var.org_name
  vdc           = var.vdc_name
  vapp_name     = vcd_vapp.this[coalesce(each.value["vapp_name"], var.vapp_name, each.key)].name
  name          = each.key
  computer_name = coalesce(each.value["computer_name"], each.key)
  catalog_name  = coalesce(each.value["catalog_name"], var.catalog_name)
  template_name = coalesce(each.value["template_name"], var.template_name)
  memory        = coalesce(each.value["memory"], var.memory)
  cpus          = coalesce(each.value["cpus"], var.cpus)
  cpu_cores     = coalesce(each.value["cpu_cores"], var.cpu_cores)

  dynamic "override_template_disk" {
    for_each = try(
      coalesce(each.value["override_template_disk"]),
      coalesce(var.override_template_disk),
      []
    )
    content {
      bus_type        = try(override_template_disk.value["bus_type"], "paravirtual")
      size_in_mb      = override_template_disk.value["size_in_mb"]
      bus_number      = try(override_template_disk.value["bus_numer"], 0)
      unit_number     = try(override_template_disk.value["unit_number"], 0)
      iops            = try(override_template_disk.value["iops"], null)
      storage_profile = try(override_template_disk.value["storage_profile"], null)
    }
  }

  dynamic "disk" {
    for_each = try(
      coalesce(each.value["disks"]),
      []
    )
    content {
      name        = disk.value["name"]
      bus_number  = disk.value["bus_number"]
      unit_number = disk.value["unit_number"]
    }
  }

  dynamic "network" {
    for_each = try(
      coalesce(each.value["networks"]),
      coalesce(var.networks),
      []
    )
    content {
      type       = try(network.value["type"], "org")
      # network name is in network.key, but we need to reference vcd_vapp_org_network
      # resource to ensure correct ordering for create/destroy
      name       = vcd_vapp_org_network.this["${coalesce(each.value["vapp_name"], var.vapp_name, each.key)}-${network.key}"].org_network_name
      is_primary = try(network.value["is_primary"], null)
      mac        = try(network.value["mac"], null)
      ip_allocation_mode = try(
        network.value["ip_allocation_mode"],
        network.value["ip"] == null ? "POOL" : "MANUAL"
      )
      ip = try(network.value["ip"], null)
    }
  }

  dynamic "customization" {
    for_each = try(
      coalesce(each.value["customization"]),
      coalesce(var.customization),
      []
    )
    content {
      force                      = try(customization["force"], null)
      enabled                    = try(customization["enabled"], null)
      allow_local_admin_password = try(customization["allow_local_admin_password"], null)
      auto_generate_password     = try(customization["auto_generate_password"], null)
      initscript                 = try(customization["initscript"], null)
    }
  }

  metadata = merge(
    var.metadata,
    each.value["metadata"]
  )
}
