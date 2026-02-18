# Multi-Resource Infrastructure Organization

This repository contains Terraform modules and Terragrunt configurations for GCP infrastructure.

## Directory Structure

```
terraform-gcloud/
├── terraform-modules/              # Reusable Terraform modules
│   ├── gcp-vm/                     # Compute instances
│   ├── gcp-gke/                    # GKE clusters
│   └── gcp-cloudsql/               # Cloud SQL databases
│
├── terragrunt/                     # Infrastructure as Code
│   ├── terragrunt.hcl              # Root configuration
│   │
│   └── {region}/                   # Region-specific (us-central1, us-east1)
│       ├── region.hcl              # Region settings
│       │
│       └── {environment}/          # Environment (dev, staging, prod)
│           ├── vms/                # Virtual machines
│           │   ├── terragrunt.hcl
│           │   └── vms.csv
│           │
│           ├── gke/                # Kubernetes clusters
│           │   └── terragrunt.hcl
│           │
│           ├── database/           # Cloud SQL instances
│           │   └── terragrunt.hcl
│           │
│           └── network/            # VPC, subnets, firewall
│               └── terragrunt.hcl
│
└── docs/                           # Documentation
```

## Organization Principles

### 1. **Modules by Technology** (`terraform-modules/`)
- One directory per resource type
- Reusable across environments
- Versioned independently (if needed)

### 2. **Configs by Environment** (`terragrunt/`)
- Organized: Region → Environment → Resource Type
- Each resource type has its own directory
- Separate state files per resource type

### 3. **Dependency Management**
Resources can depend on each other using Terragrunt dependencies

## Resource Organization Patterns

### Pattern A: By Resource Type (Recommended)
```
dev/
├── network/        # VPC, subnets (deploy first)
├── gke/            # GKE cluster (depends on network)
├── database/       # Cloud SQL (depends on network)
└── vms/            # VMs (depends on network)
```

### Pattern B: By Application
```
dev/
├── networking/
├── shared/         # Shared resources (GKE, databases)
└── apps/
    ├── app1/       # App1 VMs + DB
    └── app2/       # App2 VMs + DB
```

### Pattern C: By Layer
```
dev/
├── 1-foundation/   # Network, DNS
├── 2-platform/     # GKE, databases
└── 3-workloads/    # VMs, services
```

## Deployment Order

```
1. network/     → Create VPC and subnets
2. database/    → Create Cloud SQL (uses network)
3. gke/         → Create GKE cluster (uses network)
4. vms/         → Create VMs (uses network)
```

## Common Commands

### Deploy all resources in dev environment
```bash
cd terragrunt/us-central1/dev
terragrunt run-all apply
```

### Deploy specific resource type
```bash
cd terragrunt/us-central1/dev/gke
terragrunt apply
```

### Deploy with dependencies
```bash
cd terragrunt/us-central1/dev/vms
terragrunt apply  # Auto-applies network if configured as dependency
```

## State File Organization

Each resource type gets its own state file:
```
gs://bucket/us-central1/dev/network/terraform.tfstate
gs://bucket/us-central1/dev/gke/terraform.tfstate
gs://bucket/us-central1/dev/database/terraform.tfstate
gs://bucket/us-central1/dev/vms/terraform.tfstate
```

## Benefits

✅ **Blast Radius Control** - Issues in VMs don't affect GKE
✅ **Parallel Development** - Teams work on different resources
✅ **Selective Deployment** - Deploy only what changed
✅ **Clear Dependencies** - Explicit resource relationships
✅ **Easier Rollbacks** - Rollback specific resource types
