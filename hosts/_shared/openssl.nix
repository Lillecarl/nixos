{ lib, config, ... }:
let
  modName = "openssl";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.etc."ssl/openssl.cnf".text = ''
      # Minimal OpenSSL configuration
      openssl_conf = openssl_init

      [openssl_init]
      providers = provider_sect

      [provider_sect]
      default = default_sect

      [default_sect]
      activate = 1
    '';
  };
}
