{ lib
, nixosConfig ? { }
, ...
}:
{
  options = {
    ps = {
      gui = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            If we should configure GUI/Wayland applications.
          '';
        };
        systemdTarget = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "The systemd target to bind GUI services to";
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
          type  = lib.types.enum [
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
