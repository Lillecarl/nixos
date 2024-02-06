{ self
, pkgs
, bp
, config
, ...
}:
let
  lockScript = bp (pkgs.writeShellScriptBin "swayLockScript" ''
    ${bp config.programs.rbw.package} lock
    ${bp pkgs.swaylock}
    ${bp config.programs.rbw.package} unlock
  '');
in
{
  home.file."swayLockScript" = {
    target = ".local/bin/swayLockScript";
    source = lockScript;
  };


  programs.swaylock = {
    enable = true;

    settings = {
      daemonize = true;
      image = "${self}/resources/lockscreen.jpg";
      scaling = "center";
      color = "000000";
    };
  };

  services.swayidle = {
    enable = true;

    systemdTarget = "hyprland-session.target";

    events = [
      { event = "before-sleep"; command = lockScript; }
      { event = "lock"; command = lockScript; }
    ];

    timeouts = [
      { timeout = 300; command = lockScript; }
      { timeout = 600; command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; }
    ];
  };
}
