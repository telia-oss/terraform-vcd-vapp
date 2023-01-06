resource "vcd_vapp" "this" {
  org      = var.org_name
  vdc      = var.vdc_name
  name     = var.vapp_name != null ? var.vapp_name : var.vdc_name
  metadata = var.metadata
}

resource "vcd_vapp_org_network" "this" {
  for_each = toset(
    flatten(
      [
        for vm in var.vms : keys(vm["networks"]) if vm["networks"] != null
      ]
    )
  )
  vdc              = var.vdc_name
  vapp_name        = vcd_vapp.this.name
  org_network_name = each.value
}

resource "vcd_vm_internal_disk" "this" {
  for_each = merge(
    [
      for name, vm in var.vms :
      {
        for i, disk in concat(var.internal_disks, vm["internal_disks"]) :
        "${name}-${i}" => merge(
          disk,
          { vm_name = name }
        )
      } if vm["internal_disks"] != null
    ]...
  )
  vdc             = var.vdc_name
  vapp_name       = vcd_vapp.this.name
  vm_name         = each.value["vm_name"]
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
  vapp_name     = vcd_vapp.this.name
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
      name       = network.key
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
