{
  lib,
  config,
  nixosConfig ? { },
  ...
}:
{
  options = {
    ps = {
      info = {
        name = lib.mkOption {
          type = lib.types.str;
        };
        emailDomain = lib.mkOption {
          type = lib.types.str;
        };
        emailPrivate = lib.mkOption {
          type = lib.types.str;
        };
        emailWork = lib.mkOption {
          type = lib.types.str;
        };
        serviceDomain = lib.mkOption {
          type = lib.types.str;
        };
      };
      gui = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            If we should configure GUI/Wayland applications.
          '';
        };
      };
      terminal = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            If we should configure a neat terminal experience
          '';
        };
        nerdfonts = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            If the terminal we use supports nerdfonts (Loads of extra icons)
            then we want to configure applications to use them.
          '';
        };
        true-color = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            If the terminal we use supports true-color (24) colorspace.
          '';
        };
        mode = lib.mkOption {
          type = lib.types.enum [
            "slim"
            "fat"
          ];
          default = "slim";
          description = ''
            If the terminal experience should be slimmed down to the "semi-bare-minimum"
            to remote into other machines.
          '';
        };
      };
      editors = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            If we should configure text editors
          '';
        };

        mode = lib.mkOption {
          type = lib.types.enum [
            "slim"
            "fat"
          ];
          default = "slim";
          description = ''
            If we should configure our editors with heavy tools such as language
            servers and formatters.
          '';
        };
      };
      bluetooth = {
        enable = lib.mkEnableOption "Enable Bluetooth";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = nixosConfig.networking.hostName or "hostname";
        description = ''
          Configures $HOST variable
        '';
      };
    };
  };
}
