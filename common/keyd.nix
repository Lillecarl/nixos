{ lib, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.keyd
  ];
  users.groups.keyd = { };
  systemd.services.keyd = {
    serviceConfig = lib.mkForce {
      ExecStart = "${pkgs.keyd}/bin/keyd";
      Restart = "always";
    };
  };
  services.keyd = {
    enable = true;

    keyboards = {
      default = {
        ids = [ "0001:0001" ];
        extraConfig = ''
          include ${pkgs.keyd}/share/keyd/layouts/se

          [global]
          default_layout=us

          [main]
          capslock=overload(ctrl_vim, esc)
          esc=overload(swe_mode, esc)
          rightalt=layer(swe_mode)

          [ctrl_vim:C]
          e=setlayout(us)
          s=setlayout(se)
          space=swap(vim_mode)

          [swe_mode]
          '=macro(compose a ")
          ;=macro(compose o ")
          [=macro(compose a  *)

          [vim_mode:C]
          b=C-left
          h=left
          j=down
          k=up
          l=right
          w=C-right
        '';
      };
    };
  };
}
