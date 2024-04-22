{ config
, lib
, ...
}:
let
  cfg = config.carl.gui.wlogout;
in
{
  options.carl.gui.wlogout = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile."wlogout/layout.json".text = /* json */ ''
      {
          "label" : "lock",
          "action" : "swaylock",
          "text" : "Lock",
          "keybind" : "l"
      }
      {
          "label" : "logout",
          "action" : "loginctl terminate-user $USER",
          "text" : "Logout",
          "keybind" : "e"
      }
      {
          "label" : "shutdown",
          "action" : "systemctl poweroff",
          "text" : "Shutdown",
          "keybind" : "s"
      }
      {
          "label" : "suspend",
          "action" : "systemctl suspend",
          "text" : "Suspend",
          "keybind" : "u"
      }
      {
          "label" : "reboot",
          "action" : "systemctl reboot",
          "text" : "Reboot",
          "keybind" : "r"
      }
    '';
  };
}
