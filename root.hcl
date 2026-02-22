# Root Terragrunt configuration
# This file contains common configuration that can be inherited by child terragrunt.hcl files

# Terraform Cloud backend configuration (manual generation for correct syntax)
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "remote" {
    organization = "novicezeng"
    
    workspaces {
      name = "terragrunt-${replace(path_relative_to_include(), "/", "-")}"
    }
  }
}
EOF
}

# Backup bucket for disaster recovery (optional but recommended)
# Uncomment and configure if using automated backups
# backup_state {
#   backend = "remote"
#   config = {
#     organization = "novice-zeng-org-backup"
#     workspaces = {
#       name = "backup-terragrunt-${replace(path_relative_to_include(), "/", "-")}"
#     }
#   }
# }

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  # Best Practice: Use service account for production
  # Set GOOGLE_APPLICATION_CREDENTIALS env var or use ADC
  project = var.project_id
  
  # Optional: Set default region
  region = "us-central1"
}
EOF
}

# Common inputs inherited by all child modules
inputs = {
  # GCP project ID - shared across all services (IAM, VMs, GKE, etc.)
  project_id = "project-novice-486516"
}
