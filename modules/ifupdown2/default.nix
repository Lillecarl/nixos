{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.ifupdown2;
in
{
  options = {
    networking.ifupdown2 = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc ''
          Whether to enable ifupdown2 for device configuration. 
        '';
      };
      extraConfig = mkOption {
        type = types.lines;
        default = null;
        description = lib.mdDoc ''
          /etc/network/interfaces configuration
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."network/interfaces".text = cfg.extraConfig;
    environment.etc."network/ifupdown2/addons.conf".source = ./addons.conf;
    environment.etc."network/ifupdown2/ifupdown2.conf".source = ./ifupdown2.conf;

    systemd.services.ifupdown2 = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network.target" ];
      before = [ "network-online.target" ];
      restartTriggers = [
        config.environment.etc."network/interfaces".source
        config.environment.etc."network/ifupdown2/ifupdown2.conf".source
      ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "ifreload-helper" ''
          ${pkgs.ifupdown2}/bin/ifreload --all --syntax-check
          ${pkgs.ifupdown2}/bin/ifreload --all
        '';
        RemainAfterExit = true;
      };

      #restartIfChanged = true;
    };
  };
}
