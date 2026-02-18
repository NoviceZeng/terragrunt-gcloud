# Include root configuration
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

# Include region configuration
include "region" {
  path = find_in_parent_folders("region.hcl")
}

# Use the GKE module
terraform {
  source = "../../../../terraform-modules/gcp-gke"
}

locals {
  env         = "dev"
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.region
}

# Dependencies - GKE needs network to exist first
dependency "network" {
  config_path = "../network"
  
  # Mock outputs for planning when network doesn't exist yet
  mock_outputs = {
    network_name    = "default"
    subnetwork_name = "dev-subnet"
  }
}

inputs = {
  cluster_name = "${local.env}-gke-cluster"
  region       = local.region
  
  # Use network from dependency
  network    = dependency.network.outputs.network_name
  subnetwork = dependency.network.outputs.subnetwork_name
  
  # Cluster configuration
  enable_autopilot        = false
  enable_private_nodes    = true
  enable_private_endpoint = false
  
  # Node pool configuration
  machine_type      = "e2-medium"
  node_count        = 1
  min_node_count    = 1
  max_node_count    = 3
  preemptible_nodes = true  # Cost savings for dev
  
  node_labels = {
    environment = local.env
    managed-by  = "terragrunt"
  }
  
  node_tags = ["gke-node", local.env]
}
