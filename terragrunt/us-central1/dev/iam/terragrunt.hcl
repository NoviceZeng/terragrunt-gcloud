# Include root configuration
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

# Include region configuration
include "region" {
  path = find_in_parent_folders("region.hcl")
}

# Use the consolidated IAM roles module
terraform {
  source = "../../../../terraform-modules/gcp-iam-roles"
}

locals {
  env = "dev"
}

inputs = {
  project_id = "your-gcp-project-id"
  
  # Define all custom IAM roles in one place
  roles = {
    # EC2/Compute custom role
    ec2_admin = {
      role_id     = "${local.env}-ec2-admin"
      title       = "Dev EC2/Compute Admin Role"
      description = "Custom role for EC2/Compute instance management in dev environment"
      permissions = [
        "compute.instances.get",
        "compute.instances.list",
        "compute.instances.create",
        "compute.instances.delete",
        "compute.instances.setMetadata",
        "compute.instances.setServiceAccount",
        "compute.networks.get",
        "compute.subnetworks.get",
      ]
      members = [
        # "user:dev-team@example.com"
      ]
      service_account_emails = [
        # "service-account@project.iam.gserviceaccount.com"
      ]
    }
    
    # GCS/Cloud Storage custom role
    gcs_editor = {
      role_id     = "${local.env}-gcs-editor"
      title       = "Dev GCS/Cloud Storage Editor Role"
      description = "Custom role for GCS (Cloud Storage) management in dev environment"
      permissions = [
        "storage.buckets.get",
        "storage.buckets.list",
        "storage.buckets.update",
        "storage.objects.get",
        "storage.objects.list",
        "storage.objects.create",
        "storage.objects.delete",
        "storage.objects.update",
        "storage.objects.copy"
      ]
      members = [
        # "user:dev-team@example.com"
      ]
      service_account_emails = [
        # "service-account@project.iam.gserviceaccount.com"
      ]
    }
    
    # Add more roles as needed
    # database_admin = {
    #   role_id     = "${local.env}-database-admin"
    #   title       = "Dev Database Admin Role"
    #   description = "Custom role for database management"
    #   permissions = [...]
    #   members     = [...]
    #   service_account_emails = [...]
    # }
  }
}
