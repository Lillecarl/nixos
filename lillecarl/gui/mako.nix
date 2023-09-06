{ ... }:
{
  services.mako = {
    enable = true;

    anchor = "center";

    extraConfig = ''
      [summary="Du presenterar för alla"]
      invisible=1
    '';
  };
}
