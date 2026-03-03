# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../terraform-modules/gcp-network"
}

locals {
  env = "dev"

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.region
}

inputs = {
  network_name = local.region_vars.locals.vpc_name

  subnets = [
    {
      name          = "${local.env}-vm-subnet"
      ip_cidr_range = "10.0.1.0/24"
      region        = local.region
    },
    {
      name          = "${local.env}-services-subnet"
      ip_cidr_range = "10.0.2.0/24"
      region        = local.region
    }
  ]
}
