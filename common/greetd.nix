{ pkgs
, ...
}:
{
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        user = "lillecarl";
        command = "${pkgs.hyprland}/bin/Hyprland";
      };
    };
  };
}
