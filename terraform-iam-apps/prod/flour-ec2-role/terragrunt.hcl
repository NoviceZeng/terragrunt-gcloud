include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path = "../../_envcommon/flour_ec2_role.hcl"
}

terraform {
  source = "../../modules//role-flour-ec2-instance"
}