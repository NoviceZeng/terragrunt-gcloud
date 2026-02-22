# Region-specific configuration for us-central1
# Inherits from root terragrunt.hcl
# Best Practice: Each region has isolated IP ranges

locals {
  # Region identifier
  region = "us-central1"
  zones  = ["us-central1-a", "us-central1-b", "us-central1-c"]
  
  # VPC network name (follow pattern: {project}-vpc-{region})
  vpc_name = "acme-vpc-us-central1"
  
  # Best Practice: Separate IP ranges per environment
  # Dev:  10.0.0.0/16   (Dev VMs, non-critical workloads)
  # Prod: 10.1.0.0/16   (Production workloads)
  dev_ip_range  = "10.0.0.0/16"
  prod_ip_range = "10.1.0.0/16"
  
  # Firewall rule naming convention: {project}-fw-{region}-{purpose}
  fw_prefix = "acme-fw-us-central1"
  
  # Service account naming: {project}-sa-{role}-{region}
  sa_prefix = "acme-sa"
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
