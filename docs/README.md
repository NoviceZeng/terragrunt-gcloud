# GCP Infrastructure as Code - Complete Documentation

Welcome to the GCP Infrastructure as Code repository! This guide covers the entire setup, structure, and usage.

## Quick Start

### Prerequisites
- Terragrunt v0.45.0+
- Terraform v1.0+
- Google Cloud SDK configured
- GCS bucket for state storage

### Deploy Infrastructure

```bash
# Deploy all resources in dev environment
cd terragrunt/us-central1/dev
terragrunt run-all apply

# Deploy specific resource (e.g., VMs)
cd terragrunt/us-central1/dev/vms
terragrunt apply

# Deploy across all regions
cd terragrunt
terragrunt run-all apply
```

## Repository Structure

```
terraform-gcloud/
├── docs/                               # Documentation
│   ├── README.md                       # This file
│   ├── SETUP.md                        # Setup & configuration guide
│   ├── ARCHITECTURE.md                 # Architecture overview
│   └── MODULES.md                      # Module reference
│
├── terraform-modules/                  # Reusable Terraform modules
│   ├── gcp-vm/                         # Virtual machines
│   ├── gcp-gke/                        # GKE clusters
│   ├── gcp-cloudsql/                   # Cloud SQL databases
│   └── gcp-iam-roles/                  # Custom IAM roles
│
├── terragrunt/                         # Infrastructure configurations
│   ├── terragrunt.hcl                  # Root config
│   ├── us-central1/                    # Region
│   │   ├── region.hcl
│   │   ├── dev/
│   │   │   ├── vms/
│   │   │   ├── gke/
│   │   │   ├── database/
│   │   │   └── iam/
│   │   └── prod/
│   │       ├── vms/
│   │       ├── gke/
│   │       ├── database/
│   │       └── iam/
│   └── us-east1/
│       └── [same structure as us-central1]
│
├── ORGANIZATION.md                     # Overall organization patterns
└── terragrunt.hcl                      # Root Terragrunt config
```

## Key Concepts

### Three-Level Hierarchy

The configuration uses a hierarchical structure for maximum flexibility:

**Level 1: Root** (`terragrunt/terragrunt.hcl`)
- Global defaults
- Backend configuration
- Provider setup

**Level 2: Region** (`terragrunt/{region}/region.hcl`)
- Region-specific settings
- Available zones
- IP ranges
- Regional resources

**Level 3: Environment** (`terragrunt/{region}/{env}/{resource}/terragrunt.hcl`)
- Resource-specific configurations
- Environment-specific settings
- Resource definitions

### Resource Organization

All resources are organized at the same layer within each environment:
- `vms/` - Virtual machine instances
- `gke/` - Kubernetes clusters
- `database/` - Cloud SQL databases
- `iam/` - Custom IAM roles

### State File Organization

Each resource type gets its own state file:
```
gs://bucket/us-central1/dev/vms/terraform.tfstate
gs://bucket/us-central1/dev/gke/terraform.tfstate
gs://bucket/us-central1/dev/database/terraform.tfstate
gs://bucket/us-central1/dev/iam/terraform.tfstate
```

## Common Tasks

### Deploy Infrastructure

```bash
# Deploy all resources in a region
cd terragrunt/us-central1
terragrunt run-all apply

# Deploy specific environment
cd terragrunt/us-central1/dev
terragrunt run-all apply

# Deploy single resource type
cd terragrunt/us-central1/dev/vms
terragrunt apply
```

### Plan Changes

```bash
# Plan all changes in region
cd terragrunt/us-central1
terragrunt run-all plan

# Plan specific resource
cd terragrunt/us-central1/prod/gke
terragrunt plan
```

### Add New Resource

1. Create resource directory: `terragrunt/us-central1/dev/{resource}/`
2. Create `terragrunt.hcl` with module reference
3. Add resource-specific configuration
4. Run `terragrunt apply`

### Add New Region

1. Copy region template: `cp -r terragrunt/us-central1 terragrunt/europe-west1`
2. Update `region.hcl` with new region settings
3. Update environment configurations
4. Deploy: `cd terragrunt/europe-west1 && terragrunt run-all apply`

### Add New Environment

1. Create environment directory in region
2. Copy environment structure from another environment
3. Update environment-specific values
4. Deploy: `terragrunt run-all apply`

## Documentation Files

- **SETUP.md** - Initial setup and configuration steps
- **ARCHITECTURE.md** - Detailed architecture and design decisions
- **MODULES.md** - Module reference and variable documentation
- **ORGANIZATION.md** - Organization patterns and best practices

See individual files for detailed information.
