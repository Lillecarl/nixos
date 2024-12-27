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
  backend "s3" {
    # Get credentials and endpoints from environment variables
    region = "us-east-1"
    bucket = "postspace-tfstate"
    key    = "${path_relative_to_include()}.tfstate"
    # ignore this for r2 compatibility
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
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
