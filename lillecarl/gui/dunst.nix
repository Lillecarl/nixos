{ inputs
, pkgs
, ...
}:
{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 10;
        frame_color = "#eceff1";
        font = "Droid Sans 9";

        icon_path = "/run/current-system/sw/share/icons/";
      };

      urgency_normal = {
        background = "#37474f";
        foreground = "#eceff1";
        timeout = 10;
      };
    };
  };
}
