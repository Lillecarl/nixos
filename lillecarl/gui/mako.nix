{ ... }:
{
  services.mako = {
    enable = true;

    anchor = "center";

    extraConfig = ''
      [summary="Du presenterar för alla"]
      invisible=1
      [summary="Connection Established"]
      default-timeout=15000
    '';
  };
}
