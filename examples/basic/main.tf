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
          bus_number  = 1
          unit_number = 0
        }
      ]
      networks = {
        vapp_name = "my_custom_vapp"
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
