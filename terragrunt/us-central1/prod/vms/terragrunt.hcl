# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Include region configuration
include "region" {
  path = find_in_parent_folders("region.hcl")
}

# Use the VMs module
terraform {
  source = "../../../../terraform-modules/gcp-vm"
}

locals {
  # Environment identifier
  env = "prod"
  
  # Get region config
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.region
  
  # Environment settings (dynamic based on env)
  subnet = "projects/your-gcp-project-id/regions/${local.region}/subnetworks/${local.env}-subnet"
  
  # Parse CSV
  csv_content = file("${get_terragrunt_dir()}/vms.csv")
  csv_lines   = split("\n", local.csv_content)
  csv_data    = [for line in slice(local.csv_lines, 1, length(local.csv_lines)) : split(",", line) if line != ""]
  
  # Transform to VM objects
  vms = [for vm in local.csv_data : {
    name         = vm[0]
    hostname     = vm[1]
    machine_type = vm[2]
    zone         = vm[3]
    ip           = vm[4]
    disk         = vm[5] != "" ? vm[5] : null
    subnetname   = vm[6] != "" ? vm[6] : local.subnet
    bootimage    = vm[7] != "" ? vm[7] : null
    bootdisksize = vm[8] != "" ? tonumber(vm[8]) : null
    tags         = vm[9] != "" ? split("|", vm[9]) : []
  }]
}

inputs = {
  vms = local.vms
  
  # Dynamic naming based on region and env
  firewall_name_prefix   = "${local.region}-${local.env}"
  service_account_prefix = "${local.region}-${local.env}"
  
  # Environment-specific security settings
  ssh_source_ranges      = ["203.0.113.0/24"]  # Restrict to office IP
  internal_source_ranges = [local.region_vars.locals.prod_ip_range]
}
