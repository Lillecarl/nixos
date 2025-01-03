terraform {
  extra_arguments "TF_IN_AUTOMATION" {
    commands = [
      "apply",
      "destroy",
      "output",
      "plan",
      "refresh",
      "init",
    ]
    env_vars = {
      TF_IN_AUTOMATION   = "1"
      TF_CLI_CONFIG_FILE = get_env("TF_CLI_CONFIG_FILE")
    }
  }
  extra_arguments "pluginDir" {
    commands = ["init"]
    arguments = [
      "-plugin-dir=${get_env("TF_PLUGIN_CACHE_DIR")}"
    ]
  }
}
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
dependencies {
  paths = (
    !strcontains(get_original_terragrunt_dir(), "stage1") &&
    !strcontains(get_original_terragrunt_dir(), "prometheus-crd")
  ) ? ["../prometheus-crd"] : []

}
