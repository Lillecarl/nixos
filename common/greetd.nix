{ inputs
, pkgs
, ...
}:
{
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --user-menu --asterisks --time --cmd ${pkgs.hyprland}/bin/Hyprland";
      };
    };
  };
}
