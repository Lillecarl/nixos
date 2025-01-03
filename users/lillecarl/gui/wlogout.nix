{ lib, config, ... }:
{
  config = lib.mkIf config.ps.gui.enable {
    xdg.configFile."wlogout/layout.json".text = # json
      ''
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
