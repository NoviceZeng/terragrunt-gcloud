# Include root configuration
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

# Include region configuration
include "region" {
  path = find_in_parent_folders("region.hcl")
}

# Use the Cloud SQL module
terraform {
  source = "../../../../terraform-modules/gcp-cloudsql"
}

locals {
  env         = "prod"
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region      = local.region_vars.locals.region
}

# Dependencies - Database needs network for private IP
dependency "network" {
  config_path = "../network"
  
  mock_outputs = {
    network_id   = "projects/my-project/global/networks/default"
    network_name = "default"
  }
}

inputs = {
  instance_name    = "${local.env}-postgres-db"
  region           = local.region
  database_version = "POSTGRES_15"
  
  # Production instance configuration
  tier              = "db-custom-2-7680"  # 2 vCPU, 7.5GB RAM
  availability_type = "REGIONAL"          # High availability
  disk_size         = 100
  disk_type         = "PD_SSD"
  
  # Network configuration
  ipv4_enabled    = false  # No public IP
  private_network = dependency.network.outputs.network_id
  require_ssl     = true
  
  # Backup configuration (full for production)
  backup_enabled                     = true
  backup_start_time                  = "02:00"
  point_in_time_recovery_enabled     = true
  transaction_log_retention_days     = 7
  
  # Maintenance
  maintenance_window_day  = 7  # Sunday
  maintenance_window_hour = 3
  
  # Protection
  deletion_protection = true  # Prevent accidental deletion
  
  # Databases to create
  databases = ["app_db"]
  
  # Users (use Secret Manager in production!)
  users = {
    app_user  = "CHANGE_ME_USE_SECRET_MANAGER"
    read_user = "CHANGE_ME_USE_SECRET_MANAGER"
  }
}
