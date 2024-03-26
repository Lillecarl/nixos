{ pkgs
, lib
, ...
}:
let
  commands = lib.concatStringsSep ";" [
    # Since we're using fish to launch hyprland, unset gate variables
    "set -e __HM_SESS_VARS_SOURCED"
    "set -e __NIXOS_SET_ENVIRONMENT_DONE"
    "set -e __fish_home_manager_config_sourced"
    "set -e __fish_nixos_general_config_sourced"
    "set -e __fish_nixos_interactive_config_sourced"
    "set -e __fish_nixos_login_config_sourced"
    "exec ${lib.getExe pkgs.hyprland}"
  ];
in
{
  services.greetd = {
    enable = false;

    settings = {
      default_session = {
        user = "lillecarl";
        command = "${lib.getExe pkgs.fish} -l -c '${commands}'";
      };
    };
  };
}
