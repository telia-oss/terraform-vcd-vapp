<!-- BEGIN_TF_DOCS -->
Create a vApp with a set of VMs in vCloud Director

This module creates the `vcd_vapp` resource as well as `vcd_vapp_vm` resources along with any `vcd_vm_internal_disk`s or `vcd_vapp_org_network`s that are required. Other resources (like `vcd_independent_disk`s to be attached) will have to be created outside of this module. It assumes that the `vcd` provider has already been configured.

VMs are created by passing a `map` called `vms` of their names to their parameters to the module. Configuring VM parameters is done in two ways:
- Passing a parameter with the appropriate value to the module - this sets a default for all VMs that will be created.
- Adding an attribute to the appropriate object in the `vms` map - this will set a VM-specific parameter or override the module default.

Names and formats of the parameters were taken from the [vcd](https://registry.terraform.io/providers/vmware/vcd/latest/docs) module to avoid confusion.

Here is an example of how this module could be used:
```hcl
module "my_web_app" {
  source        = "telia-oss/vapp/vcd"
  org_name      = "my_organisation"
  vdc_name      = "datacenter1"
  vapp_name     = "my_web_vapp"
  catalog_name  = "internal_image_catalog"
  template_name = "ubuntu-22.04"
  memory        = 2
  cpus          = 1
  cpu_cores     = 2
  vms = {
    web1 = {
      disks = [
        {
          name        = "backups"
          size_in_mb  = 1024 * 100
          bus_number  = 1
          unit_number = 0
        }
      ]
      networks = {
        "external_network" = { ip = "1.0.0.1" }
      }
    }
    web2 = {
      networks = {
        "external_network" = { ip = "1.0.0.2" }
      }
    }
  }
  metadata = {
    app = "my_app"
    role = "web"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vcd"></a> [vcd](#provider\_vcd) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vapp_name"></a> [vapp\_name](#input\_vapp\_name) | Name of the vApp that will be created | `string` | n/a | yes |
| <a name="input_vms"></a> [vms](#input\_vms) | Map of VM names and their desired configurations | <pre>map(<br>    object(<br>      {<br>        computer_name = optional(string)<br>        catalog_name  = optional(string)<br>        template_name = optional(string)<br>        memory        = optional(number)<br>        cpus          = optional(number)<br>        cpu_cores     = optional(number)<br>        internal_disks = optional(<br>          list(<br>            object(<br>              {<br>                allow_vm_reboot = optional(bool)<br>                bus_type        = string<br>                size_in_mb      = number<br>                bus_number      = number<br>                unit_number     = number<br>                iops            = optional(number)<br>                storage_profile = optional(string)<br>              }<br>            )<br>          )<br>        )<br>        override_template_disk = optional(object({}))<br>        disks = optional(<br>          list(<br>            object(<br>              {<br>                name        = string<br>                bus_number  = number<br>                unit_number = number<br>              }<br>            )<br>          )<br>        )<br>        networks = optional(<br>          map(<br>            object(<br>              {<br>                ip  = optional(string)<br>                mac = optional(string)<br>              }<br>            )<br>          )<br>        )<br>        customization = optional(object({}))<br>        metadata      = optional(map(string))<br>      }<br>    )<br>  )</pre> | n/a | yes |
| <a name="input_catalog_name"></a> [catalog\_name](#input\_catalog\_name) | Default catalog name to use for VMs | `string` | `null` | no |
| <a name="input_cpu_cores"></a> [cpu\_cores](#input\_cpu\_cores) | Default value for "cpu\_cores" for VMs | `number` | `null` | no |
| <a name="input_cpus"></a> [cpus](#input\_cpus) | Default value for "cpus" for VMs | `number` | `null` | no |
| <a name="input_customization"></a> [customization](#input\_customization) | Default values for the VM "customization" block | `object({})` | `null` | no |
| <a name="input_internal_disks"></a> [internal\_disks](#input\_internal\_disks) | List of default internal disks for all VMs | <pre>list(<br>    object(<br>      {<br>        allow_vm_reboot = optional(bool)<br>        bus_type        = string<br>        size_in_mb      = number<br>        bus_number      = number<br>        unit_number     = number<br>        iops            = optional(number)<br>        storage_profile = optional(string)<br>      }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Default value for "memory" for VMs | `number` | `null` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Metadata to assign to all created resources | `map(string)` | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | Default network configuration for all VMs | `object({})` | `null` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | vCloud Director Org name to use | `string` | `null` | no |
| <a name="input_override_template_disk"></a> [override\_template\_disk](#input\_override\_template\_disk) | Override the (template) disk in VMs to this configuration | `map(any)` | `null` | no |
| <a name="input_template_name"></a> [template\_name](#input\_template\_name) | Default template name to use for VMs | `string` | `null` | no |
| <a name="input_vdc_name"></a> [vdc\_name](#input\_vdc\_name) | VCD name to use | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_networks"></a> [networks](#output\_networks) | Name-indexed list of vcd\_vapp\_org\_network resources that were attached to this vApp |
| <a name="output_vapp"></a> [vapp](#output\_vapp) | The vcd\_vapp resource created by this module |
| <a name="output_vms"></a> [vms](#output\_vms) | Name-indexed list of VM resources created in this module |
<!-- END_TF_DOCS -->