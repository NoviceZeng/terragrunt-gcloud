# Region-specific configuration for us-east1
# Inherits from root terragrunt.hcl

locals {
  region = "us-east1"
  zones  = ["us-east1-b", "us-east1-c", "us-east1-d"]
  
  # Region-specific network settings
  vpc_name = "default"
  
  # Region-specific IP ranges
  dev_ip_range  = "10.2.0.0/16"
  prod_ip_range = "10.3.0.0/16"
}

# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Region-level inputs (merged with root and can be overridden by environment)
inputs = {
  region  = local.region
  network = local.vpc_name
}
