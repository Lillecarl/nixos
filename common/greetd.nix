{ pkgs
, bp
, ...
}:
{
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        user = "lillecarl";
        command = bp pkgs.hyprland;
      };
    };
  };
}
