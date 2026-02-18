# GCS Bucket Configuration - Best Practices

## Demo Bucket Names Used

This project uses the following demo bucket naming pattern:

```
{organization}-terraform-state-{environment}
```

### Examples
- **Production:** `acme-terraform-state-prod`
- **Development:** `acme-terraform-state-dev`
- **Backup:** `acme-terraform-state-backup`

### Bucket Naming Convention

**Pattern:** `{org}-terraform-state-{env}-{region}`

| Bucket Name | Purpose | Environment | Versioning |
|------------|---------|-------------|-----------|
| `acme-terraform-state-prod` | Main production state | Production | ✅ Enabled |
| `acme-terraform-state-dev` | Development state | Development | ✅ Enabled |
| `acme-terraform-state-backup` | DR/Backup storage | All | ✅ Enabled |

## State File Organization

Each resource gets its own state file path:

```
gs://acme-terraform-state-prod/
├── us-central1/dev/
│   ├── vms/terraform.tfstate
│   ├── gke/terraform.tfstate
│   ├── database/terraform.tfstate
│   └── iam/terraform.tfstate
├── us-central1/prod/
│   ├── vms/terraform.tfstate
│   ├── gke/terraform.tfstate
│   ├── database/terraform.tfstate
│   └── iam/terraform.tfstate
└── us-east1/prod/
    └── ... (similar structure)
```

**Benefits:**
- ✅ Separated state files per resource
- ✅ Easy to identify which resource owns state
- ✅ Clear audit trail via versioning
- ✅ Independent backup/restore

## GCS Bucket Setup Commands

### 1. Create Main State Bucket

```bash
# Create bucket (replace PROJECT_ID with your GCP project)
gsutil mb -l us-central1 gs://acme-terraform-state-prod

# Enable versioning
gsutil versioning set on gs://acme-terraform-state-prod

# Enable uniform bucket-level access
gsutil uniformbucketlevelaccess set on gs://acme-terraform-state-prod

# Enable lifecycle to keep last 30 versions
gsutil lifecycle set - gs://acme-terraform-state-prod <<'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"numNewerVersions": 30}
      }
    ]
  }
}
EOF
```

### 2. Create Backup Bucket

```bash
gsutil mb -l us-east1 gs://acme-terraform-state-backup

gsutil versioning set on gs://acme-terraform-state-backup

gsutil uniformbucketlevelaccess set on gs://acme-terraform-state-backup
```

### 3. Configure Access Control

```bash
# Create Terraform service account
gcloud iam service-accounts create terraform \
  --display-name="Terraform Service Account"

# Grant bucket access
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member=serviceAccount:terraform@PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.objectAdmin \
  --condition='resource.name.startsWith("projects/_/buckets/acme-terraform-state")'

# Create and export key
gcloud iam service-accounts keys create ~/terraform.json \
  --iam-account=terraform@PROJECT_ID.iam.gserviceaccount.com

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS=~/terraform.json
```

### 4. Enable Encryption (Optional but Recommended)

```bash
# Create Cloud KMS key
gcloud kms keyrings create terraform --location us-central1
gcloud kms keys create state-key --location us-central1 \
  --keyring terraform --purpose encryption

# Enable on bucket
gsutil encryption set \
  projects/PROJECT_ID/locations/us-central1/keyRings/terraform/cryptoKeys/state-key \
  gs://acme-terraform-state-prod
```

### 5. Enable Audit Logging

```bash
# Create logs bucket
gsutil mb -l us-central1 gs://acme-terraform-logs

# Enable logging on state bucket
gsutil logging set on -b gs://acme-terraform-logs \
  -o terraform-access gs://acme-terraform-state-prod
```

## Terragrunt Configuration

The project is configured with these demo values:

```hcl
# terragrunt/terragrunt.hcl
remote_state {
  backend = "gcs"
  
  config = {
    bucket   = "acme-terraform-state-prod"  # ← Demo bucket
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    project  = "acme-gcp-prod-12345"        # ← Demo project ID
    location = "us-central1"
  }
}
```

## Customize for Your Organization

### Step 1: Choose Your Naming Pattern

```bash
# Organization naming examples:
# - Company: acme-terraform-state-prod
# - Department: devops-terraform-state-prod  
# - Project: project-xyz-terraform-state-prod
```

### Step 2: Update Terragrunt Configuration

Edit `terragrunt/terragrunt.hcl`:

```hcl
remote_state {
  config = {
    bucket   = "YOUR-ORG-terraform-state-prod"  # Update this
    project  = "YOUR-GCP-PROJECT-ID"            # Update this
    # ... rest stays the same
  }
}
```

### Step 3: Update Region Configuration

Edit `terragrunt/{region}/region.hcl`:

```hcl
locals {
  region = "us-central1"
  vpc_name = "YOUR-ORG-vpc-us-central1"    # Update this
  fw_prefix = "YOUR-ORG-fw-us-central1"    # Update this
  sa_prefix = "YOUR-ORG-sa"                # Update this
  # ... rest stays the same
}
```

## State File Paths (Examples)

With demo bucket `acme-terraform-state-prod`:

```
# Development VMs
gs://acme-terraform-state-prod/us-central1/dev/vms/terraform.tfstate

# Production GKE
gs://acme-terraform-state-prod/us-central1/prod/gke/terraform.tfstate

# Production Database
gs://acme-terraform-state-prod/us-central1/prod/database/terraform.tfstate

# Development IAM
gs://acme-terraform-state-prod/us-central1/dev/iam/terraform.tfstate
```

## Backup Strategy

### Automated Daily Backup

```bash
#!/bin/bash
# backup-state.sh
DATE=$(date +%Y-%m-%d)

gsutil -m cp -r \
  gs://acme-terraform-state-prod/* \
  gs://acme-terraform-state-backup/backup-${DATE}/
```

Schedule with Cloud Scheduler:
```bash
gcloud scheduler jobs create app-engine backup-terraform-state \
  --schedule="0 2 * * *" \
  --time-zone="UTC" \
  --http-method=POST \
  --uri="https://backup-function-url/"
```

## Monitoring State Changes

View recent state file modifications:

```bash
# List recent modifications
gsutil ls -L -h -r gs://acme-terraform-state-prod/ | grep "Time created:"

# Enable Cloud Audit Logs
gcloud logging sinks create terraform-state-audit \
  bigquery.googleapis.com/projects/PROJECT_ID/datasets/audit_logs \
  --log-filter='resource.type="gcs_bucket" 
               AND resource.labels.bucket_name="acme-terraform-state-prod"'
```

## Troubleshooting

### Check Bucket Versioning
```bash
gsutil versioning get gs://acme-terraform-state-prod
```

### Restore From Backup
```bash
gsutil -m cp -r \
  gs://acme-terraform-state-backup/backup-2026-02-18/* \
  gs://acme-terraform-state-prod/
```

### List State File Versions
```bash
gsutil ls -A gs://acme-terraform-state-prod/us-central1/prod/vms/
```

## Security Checklist

- [ ] Bucket versioning enabled
- [ ] Uniform bucket-level access enabled
- [ ] Public access blocked (IAM only)
- [ ] Service account has limited permissions
- [ ] Encryption enabled (KMS or managed)
- [ ] Audit logging configured
- [ ] Backup bucket configured
- [ ] Lifecycle policies set (keep 30 versions)
- [ ] Access logs enabled

## Next Steps

1. Create GCS buckets with commands above
2. Update `terragrunt/terragrunt.hcl` with your bucket names
3. Update `terragrunt/*/region.hcl` with your naming conventions
4. Set `GOOGLE_APPLICATION_CREDENTIALS` environment variable
5. Run `terragrunt init` to verify configuration
