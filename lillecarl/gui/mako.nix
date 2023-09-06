{ ... }:
{
  services.mako = {
    enable = true;

    anchor = "center";

    extraConfig = ''
      [app-name=Firefox summary="Du presenterar för alla"]
      invisible=1
    '';
  };
}
