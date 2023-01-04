variable "org_name" {
  type        = string
  description = "vCloud Director Org name to use"
  default     = null
}

variable "vdc_name" {
  type        = string
  description = "VCD name to use"
  default     = null
}

variable "vapp_name" {
  type        = string
  description = "Name of the vApp that will be created"
}

variable "vms" {
  type = map(
    object(
      {
        computer_name          = optional(string)
        catalog_name           = optional(string)
        template_name          = optional(string)
        memory                 = optional(number)
        cpus                   = optional(number)
        cpu_cores              = optional(number)
        override_template_disk = optional(object({}))
        disks = optional(
          list(
            object(
              {
                name        = string
                bus_number  = number
                unit_number = number
              }
            )
          )
        )
        networks = optional(
          map(
            object(
              {
                ip  = optional(string)
                mac = optional(string)
              }
            )
          )
        )
        customization = optional(object({}))
        metadata      = optional(map(string))
      }
    )
  )
  description = "Map of VM names and their desired configurations"
}

variable "catalog_name" {
  type        = string
  description = "Default catalog name to use for VMs"
  default     = null
}

variable "template_name" {
  type        = string
  description = "Default template name to use for VMs"
  default     = null
}

variable "memory" {
  type        = number
  description = "Default value for \"memory\" for VMs"
  default     = null
}

variable "cpus" {
  type        = number
  description = "Default value for \"cpus\" for VMs"
  default     = null
}

variable "cpu_cores" {
  type        = number
  description = "Default value for \"cpu_cores\" for VMs"
  default     = null
}

variable "override_template_disk" {
  type        = map(any)
  description = "Override the (template) disk in VMs to this configuration"
  default     = null
}

variable "networks" {
  type        = object({})
  description = "Default network configuration for all VMs"
  default     = null
}

variable "customization" {
  type        = object({})
  description = "Default values for the VM \"customization\" block"
  default     = null
}

variable "metadata" {
  type        = map(string)
  description = "Metadata to assign to all created resources"
  default     = null
}
