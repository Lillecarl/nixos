{ lib, config, ... }:
let
  modName = "waydroid";
  cfg = config.ps.${modName};
in
{
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    # How to Google apps:
    # 1. Start Waydroid
    # 2. Browse https://www.google.com/android/uncertified/
    # 3. Run the sqlite command in 'waydroid shell' to get android_id
    # 4. Register the id
    # 5. Restart Waydroid
    virtualisation.waydroid.enable = true;
  };
}
