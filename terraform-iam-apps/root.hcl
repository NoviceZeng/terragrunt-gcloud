locals {
  account = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

generate "terraform" {
  path      = "terraform.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  cloud {
    organization = "novicezeng"
    workspaces {
      name = "iam-us-east-1"
    }
  }
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}
EOF
}
