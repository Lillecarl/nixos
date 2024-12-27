include "root" { path = find_in_parent_folders("root.hcl") }

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}//${path_relative_to_include("root")}"
}

inputs = {
}
