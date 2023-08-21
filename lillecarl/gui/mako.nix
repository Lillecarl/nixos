{ ... }:
{
  services.mako = {
    enable = true;

    anchor = "center";

    extraConfig = ''
      [app-name="Firefox" body="Klicka här för att återgå till videosamtalet när du vill sluta presentera"]
      invisible=1
    '';
  };
}
