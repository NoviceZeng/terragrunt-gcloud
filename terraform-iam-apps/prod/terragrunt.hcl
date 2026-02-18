include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../role-flour-ec2"
}

include "viewer_role" {
  path = "${get_repo_root()}/roles/viewer-role.hcl"
}

include "editor_role" {
  path = "${get_repo_root()}/roles/editor-role.hcl"
}