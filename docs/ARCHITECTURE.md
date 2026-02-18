# Architecture Overview

## Design Philosophy

This infrastructure uses a **three-level hierarchical configuration** for maximum flexibility and reusability:

```
Root (Global Defaults)
    ↓
Region (Regional Settings)
    ↓
Environment (Specific Resources)
```

## Hierarchy Levels

### Level 1: Root (`terragrunt/terragrunt.hcl`)

**Scope:** Global, applies to all regions and environments

**Includes:**
- Backend configuration (GCS state storage)
- Provider setup
- Global variables
- Common settings

```hcl
inputs = {
  project_id = "your-gcp-project-id"
  bootimage  = "debian-cloud/debian-11"
  network    = "default"
}
```

### Level 2: Region (`terragrunt/{region}/region.hcl`)

**Scope:** Regional, applies to all environments in this region

**Includes:**
- Region name and zones
- Regional IP ranges
- VPC/network configuration
- Regional resource naming

```hcl
locals {
  region           = "us-central1"
  zones            = ["us-central1-a", "us-central1-b"]
  dev_ip_range     = "10.0.0.0/16"
  prod_ip_range    = "10.1.0.0/16"
}
```

### Level 3: Environment (`terragrunt/{region}/{env}/{resource}/terragrunt.hcl`)

**Scope:** Specific resource in specific environment

**Includes:**
- Resource definitions
- Environment-specific values
- Resource configurations

```hcl
inputs = {
  vms = local.vms
  firewall_name_prefix = "dev"
  ssh_source_ranges    = ["0.0.0.0/0"]
}
```

## Configuration Inheritance

```
Root terragrunt.hcl
├── project_id: "my-project"
├── bootimage: "debian-cloud/debian-11"
└── network: "default"
    │
    ├─→ us-central1/region.hcl
    │   ├── region: "us-central1"
    │   ├── dev_ip_range: "10.0.0.0/16"
    │   └── prod_ip_range: "10.1.0.0/16"
    │       │
    │       ├─→ dev/vms/terragrunt.hcl
    │       │   ├── Inherits: project_id, bootimage, region
    │       │   └── Adds: vms, firewall_name_prefix: "dev"
    │       │
    │       └─→ prod/vms/terragrunt.hcl
    │           ├── Inherits: project_id, bootimage, region
    │           └── Adds: vms, firewall_name_prefix: "prod"
    │
    └─→ us-east1/region.hcl
        └── ... (similar structure)
```

## Resource Organization

All resources are organized at the same layer within each environment:

```
terragrunt/
└── {region}/
    └── {environment}/
        ├── vms/                 # VM instances
        ├── gke/                 # GKE clusters
        ├── database/            # Cloud SQL
        └── iam/                 # Custom IAM roles
```

### Benefits

✅ **Parallel Deployment** - Each resource can be deployed independently  
✅ **Selective Updates** - Update only what changed  
✅ **Clear Blast Radius** - Issues don't cascade across resources  
✅ **State Isolation** - Each resource has its own state file  

## State File Organization

```
gs://bucket/
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
└── us-east1/
    └── ... (similar structure)
```

## Terraform Modules

All modules are in `terraform-modules/` and are **reusable** across regions and environments:

| Module | Purpose | Location |
|--------|---------|----------|
| `gcp-vm` | Virtual machine instances | `terraform-modules/gcp-vm` |
| `gcp-gke` | GKE clusters | `terraform-modules/gcp-gke` |
| `gcp-cloudsql` | Cloud SQL databases | `terraform-modules/gcp-cloudsql` |
| `gcp-iam-roles` | Custom IAM roles | `terraform-modules/gcp-iam-roles` |

## Multi-Region Support

Deploy identical infrastructure across regions:

```
terraform-gcloud/
└── terragrunt/
    ├── us-central1/  ← Same structure
    ├── us-east1/     ← Different IP ranges, regions
    └── europe-west1/ ← Can add more regions
```

**To add a new region:**
1. Copy existing region folder
2. Update `region.hcl` with new region settings
3. Deploy: `cd terragrunt/new-region && terragrunt run-all apply`

## Deployment Patterns

### Pattern 1: Deploy Everything in Region
```bash
cd terragrunt/us-central1
terragrunt run-all apply
```

### Pattern 2: Deploy Specific Environment
```bash
cd terragrunt/us-central1/dev
terragrunt run-all apply
```

### Pattern 3: Deploy Specific Resource Type
```bash
cd terragrunt/us-central1/prod/gke
terragrunt apply
```

### Pattern 4: Deploy to All Regions
```bash
cd terragrunt
terragrunt run-all apply
```

## Security Considerations

- Each environment has its own service account
- Firewall rules restrict access by default
- Database credentials stored in Secret Manager
- IAM roles follow principle of least privilege
- SSH access restricted by source IP (customizable)

## Cost Optimization

- Use preemptible nodes in dev (70% cheaper)
- Different machine types per environment
- Scheduled scaling in non-prod
- One Cloud SQL instance per environment option

See [MODULES.md](MODULES.md) for detailed module configuration options.
