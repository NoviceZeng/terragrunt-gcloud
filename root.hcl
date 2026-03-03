# Root Terragrunt configuration
# This file contains common configuration that can be inherited by child terragrunt.hcl files

# Terraform Cloud backend configuration (local execution mode)
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  cloud {
    organization = "novicezeng"
    
    workspaces {
      name = "terragrunt-${replace(path_relative_to_include(), "/", "-")}"
    }
    
    # Use local execution so Terragrunt inputs work
    # State stored in Terraform Cloud, but runs locally
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

variable "google_credentials" {
  description = "Optional GCP credentials JSON content. If null, provider falls back to ADC."
  type        = string
  default     = null
  sensitive   = true
}

provider "google" {
  # Use service account credentials from Terraform Cloud
  # Set GOOGLE_CREDENTIALS env var in Terraform Cloud
  project = var.project_id
  credentials = var.google_credentials
  
  # Optional: Set default region
  region = "us-central1"
}
EOF
}

# Common inputs inherited by all child modules
locals {
  google_credentials_from_env = get_env("GOOGLE_CREDENTIALS", "")
}

inputs = {
  # GCP project ID - shared across all services (IAM, VMs, GKE, etc.)
  project_id = "project-novice-486516"

  # Optional credentials for Terraform Cloud remote runs.
  # If empty, provider will fall back to Application Default Credentials (ADC).
  google_credentials = local.google_credentials_from_env != "" ? local.google_credentials_from_env : null
}
