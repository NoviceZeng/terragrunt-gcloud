# Root Terragrunt configuration
# This file contains common configuration that can be inherited by child terragrunt.hcl files

# Best Practice: Bucket naming: {org}-terraform-state-{env}
# Example: acme-terraform-state-prod (for production)
#          acme-terraform-state-dev (for dev/testing)
remote_state {
  backend = "gcs"
  
  config = {
    # Demo bucket name following best practices:
    # Pattern: {org}-terraform-state-{environment}
    bucket   = "acme-terraform-state-prod"
    
    # Dynamic prefix creates separate state files per resource:
    # Output: us-central1/dev/vms/terraform.tfstate
    #         us-central1/prod/gke/terraform.tfstate
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    
    # GCP project ID (update with your project)
    project  = "acme-gcp-prod-12345"
    
    # Bucket location
    location = "us-central1"
    
    # Best practices: Security and resilience settings
    skip_credentials_validation = false  # Validate credentials
    skip_bucket_versioning      = false  # Ensure versioning enabled
    skip_region_validation      = false  # Validate region settings
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Backup bucket for disaster recovery (optional but recommended)
# Uncomment and configure if using automated backups
# backup_state {
#   backend = "gcs"
#   config = {
#     bucket   = "acme-terraform-state-backup"
#     prefix   = "${path_relative_to_include()}/terraform.tfstate"
#     project  = "acme-gcp-prod-12345"
#     location = "us-central1"
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
      version = "~> 5.0"
    }
  }
}
EOF
}

# Common inputs for all environments
inputs = {
  # Shared across all environments
  project_id = "your-gcp-project-id"
  bootimage  = "debian-cloud/debian-11"
  network    = "default"
  
  # Service account configuration
  create_service_account = true
  
  # Common firewall settings
  enable_firewall_rules = true
}
