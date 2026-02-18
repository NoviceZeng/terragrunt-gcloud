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
  env         = "dev"
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
  
  # Dev instance configuration (small and cheap)
  tier              = "db-f1-micro"
  availability_type = "ZONAL"
  disk_size         = 10
  disk_type         = "PD_SSD"
  
  # Network configuration
  ipv4_enabled    = false  # No public IP
  private_network = dependency.network.outputs.network_id
  require_ssl     = true
  
  # Backup configuration (lighter for dev)
  backup_enabled                     = true
  backup_start_time                  = "02:00"
  point_in_time_recovery_enabled     = false  # Disabled for dev cost savings
  transaction_log_retention_days     = 3
  
  # Maintenance
  maintenance_window_day  = 7  # Sunday
  maintenance_window_hour = 3
  
  # Protection
  deletion_protection = false  # Allow easy deletion in dev
  
  # Databases to create
  databases = ["app_db", "test_db"]
  
  # Users (use proper secret management in production!)
  users = {
    app_user  = "dev_password_123"  # Use Secret Manager in real setup
    read_user = "readonly_456"
  }
}
