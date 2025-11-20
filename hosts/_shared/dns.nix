{ lib, config, ... }:
let
  modName = "dns";
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
    networking.nameservers = [ "9.9.9.9" ];
    services.resolved = {
      enable = true;

      dnssec = "allow-downgrade";
      dnsovertls = "opportunistic";

      fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };
    services.unbound = {
      enable = false;
      group = "users";

      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "::1"
          ];
        };
        forward-zone = [
          {
            name = ".";
            forward-addr = [
              "192.168.88.1"
              "9.9.9.9" # quad9
              "2620:fe::fe" # quad9
            ];
          }
          # Access
          {
            name = "k8s.shitbox.lillecarl.com.";
            forward-addr = "10.56.0.10";
          }
        ];
        remote-control.control-enable = true;
      };
    };
  };
}
