# Setup & Configuration Guide

## Prerequisites

### Required Tools
- **Terragrunt** v0.45.0 or later
  ```bash
  brew install terragrunt
  ```
- **Terraform** v1.0 or later
  ```bash
  brew install terraform
  ```
- **Google Cloud SDK**
  ```bash
  brew install google-cloud-sdk
  gcloud init
  gcloud auth application-default login
  ```

### GCP Setup

1. Create a GCP project
2. Enable required APIs:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable container.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   gcloud services enable iam.googleapis.com
   ```

3. Create GCS bucket for state:
   ```bash
   gsutil mb gs://your-terraform-state-bucket
   gsutil versioning set on gs://your-terraform-state-bucket
   ```

4. Set up service account for Terraform:
   ```bash
   gcloud iam service-accounts create terraform-admin \
     --display-name="Terraform Administrator"
   
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member=serviceAccount:terraform-admin@PROJECT_ID.iam.gserviceaccount.com \
     --role=roles/editor
   ```

## Configuration Steps

### 1. Update Root Configuration

Edit `terragrunt/terragrunt.hcl`:

```hcl
remote_state {
  config = {
    bucket   = "your-terraform-state-bucket"  # Update
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    project  = "your-gcp-project-id"          # Update
    location = "us-central1"
  }
}
```

### 2. Update Region Configuration

Edit `terragrunt/us-central1/region.hcl`:

```hcl
locals {
  region = "us-central1"
  zones  = ["us-central1-a", "us-central1-b", "us-central1-c"]
  
  # Update these IP ranges for your organization
  dev_ip_range  = "10.0.0.0/16"
  prod_ip_range = "10.1.0.0/16"
}
```

### 3. Update Environment Configurations

For each environment (dev, prod), update:

**Dev VM Configuration** (`terragrunt/us-central1/dev/vms/vms.csv`):
```csv
name,hostname,machine_type,zone,ip,role
dev-vm-01,dev-vm-01.example.com,e2-medium,us-central1-a,10.0.1.10,web
```

**Dev IAM Configuration** (`terragrunt/us-central1/dev/iam/terragrunt.hcl`):
```hcl
inputs = {
  project_id = "your-gcp-project-id"
  roles = {
    ec2_admin = {
      role_id     = "dev-ec2-admin"
      title       = "Dev EC2 Admin"
      members     = ["user:dev-team@example.com"]
      ...
    }
  }
}
```

### 4. Update Firewall Rules

Customize SSH access in environment configurations:

```hcl
ssh_source_ranges = ["203.0.113.0/24"]  # Your office IP
```

## First Deployment

### Dry Run

```bash
# Check what will be created
cd terragrunt/us-central1/dev
terragrunt run-all plan
```

### Deploy

```bash
# Deploy all resources
cd terragrunt/us-central1/dev
terragrunt run-all apply

# Or deploy specific resource
cd terragrunt/us-central1/dev/vms
terragrunt apply
```

### Verify Deployment

```bash
# Check created resources
gcloud compute instances list --zones us-central1-a
gcloud container clusters list --region us-central1
gcloud sql instances list
```

## Common Issues

### Issue: State File Not Found
**Solution:** Ensure GCS bucket exists and has versioning enabled
```bash
gsutil versioning set on gs://your-bucket
```

### Issue: Permission Denied
**Solution:** Check service account permissions
```bash
gcloud projects get-iam-policy PROJECT_ID
```

### Issue: Module Not Found
**Solution:** Verify paths in terragrunt.hcl source blocks
```bash
cd terragrunt/us-central1/dev/vms
terragrunt validate
```

## Environment Variables

```bash
# Set GCP project
export GOOGLE_CLOUD_PROJECT="your-gcp-project-id"

# Set Terraform environment
export TF_VAR_project_id="your-gcp-project-id"

# Enable debug logging (optional)
export TF_LOG=debug
```

## Next Steps

1. Review [ARCHITECTURE.md](ARCHITECTURE.md) for design details
2. Check [MODULES.md](MODULES.md) for module reference
3. Customize configurations for your environment
4. Deploy infrastructure
