{ lib, ... }:
{
  options.lib = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };
  config = {
    lib.cfbucket = name: {
      region = "us-east-1";
      bucket = "postspace-tfstate";
      key = "${name}.tfstate";
      # ignore this for r2 compatibility
      skip_credentials_validation = true;
      skip_region_validation = true;
      skip_requesting_account_id = true;
      skip_metadata_api_check = true;
      skip_s3_checksum = true;
    };
  };
}
