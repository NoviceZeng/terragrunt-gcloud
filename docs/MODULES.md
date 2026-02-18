# Module Reference

## Available Modules

### 1. gcp-vm (Virtual Machines)

**Location:** `terraform-modules/gcp-vm`

**Purpose:** Create and manage GCP Compute Engine instances with security features

#### Key Features
- ✅ Shielded VM enabled by default
- ✅ Automatic firewall rule creation
- ✅ Service account management
- ✅ Network tags for security policies
- ✅ Boot disk customization

#### Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `project_id` | string | Yes | - | GCP project ID |
| `vms` | list(object) | Yes | - | VM specifications |
| `enable_firewall_rules` | bool | No | true | Create firewall rules |
| `network` | string | No | "default" | VPC network name |
| `firewall_name_prefix` | string | No | "vm" | Firewall rule prefix |
| `ssh_source_ranges` | list(string) | No | ["0.0.0.0/0"] | SSH access IPs |
| `internal_source_ranges` | list(string) | No | ["10.0.0.0/8"] | Internal CIDR blocks |
| `create_service_account` | bool | No | true | Create service account |
| `service_account_prefix` | string | No | "vm" | Service account name prefix |

#### VM Object Schema

```hcl
vms = [
  {
    name               = "vm-name"          # Required
    hostname           = "vm-hostname"      # Optional
    ip                 = "10.0.1.10"        # Optional, static IP
    machine_type       = "e2-medium"        # Required
    zone               = "us-central1-a"    # Required
    region             = "us-central1"      # Optional
    bootdisksize       = 30                 # Optional, GB
    bootimage          = "debian-11"        # Optional
    subnetname         = "subnet-name"      # Optional
    tags               = ["web", "prod"]    # Optional
    enable_external_ip = true               # Optional
  }
]
```

#### Example Usage

```hcl
inputs = {
  project_id = "my-project"
  vms = [
    {
      name         = "prod-web-01"
      machine_type = "e2-standard-2"
      zone         = "us-central1-a"
      ip           = "10.1.1.10"
      bootdisksize = 30
      tags         = ["web", "prod", "http-server"]
    }
  ]
  firewall_name_prefix   = "prod"
  ssh_source_ranges      = ["203.0.113.0/24"]
  internal_source_ranges = ["10.1.0.0/16"]
  service_account_prefix = "prod"
}
```

---

### 2. gcp-gke (Kubernetes Clusters)

**Location:** `terraform-modules/gcp-gke`

**Purpose:** Create and manage GKE clusters with security best practices

#### Key Features
- ✅ Private clusters with private endpoints (optional)
- ✅ Workload Identity enabled
- ✅ Shielded node security
- ✅ Autopilot mode support
- ✅ Auto-scaling node pools

#### Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `project_id` | string | Yes | - | GCP project ID |
| `cluster_name` | string | Yes | - | GKE cluster name |
| `region` | string | Yes | - | Cluster region |
| `network` | string | Yes | - | VPC network name |
| `subnetwork` | string | Yes | - | VPC subnetwork name |
| `enable_autopilot` | bool | No | false | Use Autopilot mode |
| `enable_private_nodes` | bool | No | true | Private nodes |
| `enable_private_endpoint` | bool | No | false | Private endpoint |
| `node_count` | number | No | 1 | Nodes per zone |
| `min_node_count` | number | No | 1 | Min autoscaling nodes |
| `max_node_count` | number | No | 3 | Max autoscaling nodes |
| `machine_type` | string | No | "e2-medium" | Node machine type |
| `preemptible_nodes` | bool | No | false | Use preemptible nodes |

#### Example Usage

```hcl
inputs = {
  cluster_name        = "dev-gke-cluster"
  region              = "us-central1"
  network             = "default"
  subnetwork          = "dev-subnet"
  enable_private_nodes = true
  machine_type        = "e2-medium"
  node_count          = 1
  min_node_count      = 1
  max_node_count      = 3
  preemptible_nodes   = true  # Cost savings for dev
  node_tags           = ["gke-node", "dev"]
}
```

---

### 3. gcp-cloudsql (Cloud SQL Databases)

**Location:** `terraform-modules/gcp-cloudsql`

**Purpose:** Create and manage Cloud SQL instances with high availability options

#### Key Features
- ✅ Automated backups with point-in-time recovery
- ✅ Private IP only (no public IP by default)
- ✅ High availability (regional) option
- ✅ Multiple database versions supported
- ✅ User and database management

#### Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `project_id` | string | Yes | - | GCP project ID |
| `instance_name` | string | Yes | - | Database instance name |
| `region` | string | Yes | - | Instance region |
| `database_version` | string | No | "POSTGRES_15" | DB version |
| `tier` | string | No | "db-f1-micro" | Machine tier |
| `availability_type` | string | No | "ZONAL" | ZONAL or REGIONAL |
| `disk_size` | number | No | 10 | Disk size, GB |
| `backup_enabled` | bool | No | true | Enable backups |
| `point_in_time_recovery_enabled` | bool | No | true | Enable PITR |
| `ipv4_enabled` | bool | No | false | Public IP access |
| `require_ssl` | bool | No | true | Require SSL |
| `deletion_protection` | bool | No | true | Prevent deletion |
| `databases` | list(string) | No | [] | Database names |
| `users` | map(string) | No | {} | Users and passwords |

#### Example Usage

```hcl
inputs = {
  instance_name    = "dev-postgres-db"
  region           = "us-central1"
  database_version = "POSTGRES_15"
  tier             = "db-f1-micro"
  availability_type = "ZONAL"
  disk_size        = 10
  
  ipv4_enabled     = false  # Private IP only
  require_ssl      = true
  deletion_protection = false  # Easier to delete in dev
  
  databases = ["app_db", "test_db"]
  users = {
    app_user  = "app_password_123"
    read_user = "readonly_password_456"
  }
}
```

---

### 4. gcp-iam-roles (Custom IAM Roles)

**Location:** `terraform-modules/gcp-iam-roles`

**Purpose:** Create and manage custom IAM roles with flexible permission assignment

#### Key Features
- ✅ Multiple roles in single module (via for_each)
- ✅ Flexible permission assignment
- ✅ Support for users, groups, and service accounts
- ✅ Input validation

#### Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `project_id` | string | Yes | - | GCP project ID |
| `roles` | map(object) | Yes | - | Roles to create |

#### Role Object Schema

```hcl
roles = {
  role_key_1 = {
    role_id                = "custom-role-id"        # Required
    title                  = "Custom Role Title"      # Required
    description            = "Role description"      # Required
    permissions            = ["iam.permissions..."]  # Required
    members                = []                      # Optional
    service_account_emails = []                      # Optional
  }
}
```

#### Example Usage

```hcl
inputs = {
  project_id = "my-project"
  
  roles = {
    ec2_admin = {
      role_id     = "dev-ec2-admin"
      title       = "Dev EC2 Admin"
      description = "EC2/Compute management"
      permissions = [
        "compute.instances.get",
        "compute.instances.list",
        "compute.instances.create",
        "compute.instances.delete",
      ]
      members = ["user:dev-team@example.com"]
      service_account_emails = []
    }
    
    gcs_editor = {
      role_id     = "dev-gcs-editor"
      title       = "Dev GCS Editor"
      description = "Cloud Storage management"
      permissions = [
        "storage.buckets.get",
        "storage.objects.list",
        "storage.objects.create",
        "storage.objects.delete",
      ]
      members = ["group:dev-storage@example.com"]
      service_account_emails = ["storage-sa@project.iam.gserviceaccount.com"]
    }
  }
}
```

## Common Patterns

### Deploy Multiple Environments

```bash
# Deploy dev
cd terragrunt/us-central1/dev
terragrunt run-all apply

# Deploy prod
cd terragrunt/us-central1/prod
terragrunt run-all apply
```

### Add New Resource

Create `terragrunt/{region}/{env}/{resource}/terragrunt.hcl`:

```hcl
include "root" { path = find_in_parent_folders("terragrunt.hcl") }
include "region" { path = find_in_parent_folders("region.hcl") }

terraform {
  source = "../../../../terraform-modules/gcp-{resource}"
}

inputs = {
  # Your configuration
}
```

## Troubleshooting

### Validate Configuration
```bash
cd terragrunt/{region}/{env}/{resource}
terragrunt validate
```

### View Generated Plan
```bash
cd terragrunt/{region}/{env}/{resource}
terragrunt plan
```

### Debug Issues
```bash
export TF_LOG=DEBUG
terragrunt apply
```

For more details, see [SETUP.md](SETUP.md) and [ARCHITECTURE.md](ARCHITECTURE.md).
