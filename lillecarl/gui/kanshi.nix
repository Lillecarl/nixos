{ inputs
, config
, pkgs
, self
, ...
}:
let
  eDP1 = {
    criteria = "eDP-1";
    position = "0,0";
    mode = "1920x1200@60Hz";
    scale = 1.0;
  };
in
{
  home.packages = [
    pkgs.kanshi
  ];
  
  services.kanshi = {
    enable = true;

    systemdTarget = "hyprland-session.target";

    profiles = {
      laptop = {
        outputs = [
          eDP1
        ];
      };
      work = {
        outputs = [
          {
            criteria = "DP-2";
            position = "0,0";
            mode = "3440x1440@60Hz";
            scale = 1.0;
          }
          (eDP1 // {
            position = "760,1440";
          })
        ];
      };
    };
  };
}
