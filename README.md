# GCP Infrastructure as Code

A complete, production-ready infrastructure-as-code setup for Google Cloud Platform using Terraform and Terragrunt.

## 📚 Documentation

- **[Complete Guide](docs/README.md)** - Start here for overview and quick start
- **[Setup Guide](docs/SETUP.md)** - Prerequisites and initial configuration
- **[GCS Bucket Setup](docs/GCS_SETUP.md)** - ⭐ Bucket configuration & best practices
- **[Architecture](docs/ARCHITECTURE.md)** - Design patterns and hierarchy
- **[Modules Reference](docs/MODULES.md)** - Module details and variables
- **[Organization Patterns](ORGANIZATION.md)** - Best practices and patterns

## 🚀 Quick Start

```bash
# Deploy all resources in dev environment
cd terragrunt/us-central1/dev
terragrunt run-all apply

# Deploy specific resource
cd terragrunt/us-central1/dev/vms
terragrunt apply
```

## 📁 Structure

```
terraform-gcloud/
├── docs/                       # 📖 Documentation
├── terraform-modules/          # 🔧 Reusable Terraform modules
│   ├── gcp-vm/                # VMs
│   ├── gcp-gke/               # GKE
│   └── gcp-iam-roles/         # IAM Roles
├── terragrunt/                # ⚙️  Configurations
│   ├── shared/                # 🌐 Shared resources (IAM)
│   ├── us-central1/
│   │   ├── dev/
│   │   │   ├── vms/
│   │   │   └── gke/
│   │   └── prod/
│   │       ├── vms/
│   │       └── gke/
│   └── us-east1/
│       └── ... (similar structure)
└── ORGANIZATION.md            # 📋 Organization guide
```

## 📦 State File Organization

Each resource gets its own state file in GCS bucket (`acme-terraform-state-prod`):

```
gs://acme-terraform-state-prod/
├── shared/
│   └── iam/terraform.tfstate              # ✅ IAM roles (shared)
├── us-central1/dev/
│   ├── vms/terraform.tfstate              # ✅ VM instances
│   └── gke/terraform.tfstate              # ✅ GKE clusters
├── us-central1/prod/
│   ├── vms/terraform.tfstate
│   └── gke/terraform.tfstate
└── us-east1/prod/
    └── ... (similar structure)
```

### Benefits of Separate State Files

✅ **Reduced Blast Radius** - Issues in one resource don't cascade  
✅ **Selective Deployment** - Deploy only changed resources  
✅ **Parallel Execution** - Deploy multiple resources simultaneously  
✅ **Independent Scaling** - Manage each resource's lifecycle independently  
✅ **Clear Ownership** - Teams can own specific resource types  

### State File Configuration

Configured in `terragrunt/terragrunt.hcl`:

```hcl
remote_state {
  backend = "gcs"
  
  config = {
    bucket   = "acme-terraform-state-prod"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"  # Creates separate files
    project  = "acme-gcp-prod-12345"
  }
}
```

See [GCS Bucket Setup](docs/GCS_SETUP.md) for complete bucket configuration and best practices.

## ✨ Key Features

✅ Three-level hierarchical configuration (Global → Regional → Environment)  
✅ Modular and reusable Terraform modules  
✅ Multi-region support  
✅ Isolated state files per resource type  
✅ Comprehensive documentation  
✅ Production-ready security settings  

## 🛠️ Requirements

- Terragrunt v0.45.0+
- Terraform v1.0+
- Google Cloud SDK
- GCS bucket for state storage

## 📖 Next Steps

1. Review [State File Organization](#-state-file-organization) above
2. Read [Complete Guide](docs/README.md)
3. Follow [GCS Bucket Setup](docs/GCS_SETUP.md) - Configure your GCS bucket
4. Follow [Setup Guide](docs/SETUP.md) - Prerequisites and configuration
5. Review [Architecture](docs/ARCHITECTURE.md) - Understand the design
6. Check [Modules Reference](docs/MODULES.md) - Module details
7. Deploy infrastructure

## 📝 Resources

- [Terraform Docs](https://www.terraform.io/docs)
- [Terragrunt Docs](https://terragrunt.gruntwork.io/docs)
- [GCP Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## 📄 License

This project is provided as-is for infrastructure management.