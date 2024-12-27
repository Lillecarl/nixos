generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = file("providers.tf")
}
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<TF
terraform {
  backend "kubernetes" {}
}
TF
}

terraform {
  before_hook "terranix" {
    commands = [
      "apply",
      "plan",
      "destroy",
    ]
    execute = [
      "sh", "-c", "terranix ${get_parent_terragrunt_dir()}/config.nix > ${get_working_dir()}/config.tf.json"
    ]
    run_on_error = false
  }
}

remote_state {
  backend = "kubernetes"
  config = {
    namespace     = "default"
    secret_suffix = replace(path_relative_to_include(), "/", "-")
  }
}
