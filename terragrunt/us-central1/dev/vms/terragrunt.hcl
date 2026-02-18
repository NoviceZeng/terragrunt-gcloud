# Include root configuration
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
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
  env = "dev"
  
  # Get region config
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.region
  
  # Environment settings (dynamic based on env)
  subnet = "projects/your-gcp-project-id/regions/${local.region}/subnetworks/${local.env}-subnet"
  
  # Disk sizes by role
  disk_sizes = {
    web      = 20
    app      = 30
    database = 50
  }
  
  # Tags by role (using env variable for consistency)
  role_tags = {
    web      = ["web", local.env, "http-server", "https-server"]
    app      = ["app", local.env]
    database = ["database", local.env]
  }
  
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
    bootdisksize = local.disk_sizes[vm[5]]
    subnetname   = local.subnet
    tags         = local.role_tags[vm[5]]
  }]
}

inputs = {
  vms = local.vms
  
  # Dynamic naming based on region and env
  firewall_name_prefix   = "${local.region}-${local.env}"
  service_account_prefix = "${local.region}-${local.env}"
  
  # Environment-specific security settings
  ssh_source_ranges      = ["0.0.0.0/0"]  # Change to your office IP
  internal_source_ranges = [local.region_vars.locals.dev_ip_range]
}
