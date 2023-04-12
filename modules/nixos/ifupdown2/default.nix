{ config
, lib
, pkgs
, extraPackages ? [ ]
, ...
}:

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
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [ ];
        example = literalExpression ''
          [
            pkgs.bridge-utils
            pkgs.dpkg
            pkgs.ethtool
            pkgs.iproute2
            pkgs.kmod
            pkgs.mstpd
            pkgs.openvswitch
            pkgs.ppp
            pkgs.procps
            pkgs.pstree
            pkgs.service-wrapper
            pkgs.systemd
          ]
        '';
        description = lib.mdDoc ''
          The set of packages to add to $PATH of ifreload
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

  config = mkIf cfg.enable
    (
      let
        ifupdown2_pkg = pkgs.ifupdown2.overrideAttrs (final: prev: {
          propagatedBuildInputs = prev.propagatedBuildInputs ++ cfg.extraPackages;
        });
      in
      {
        environment.etc."network/interfaces".text = cfg.extraConfig;
        environment.etc."network/ifupdown2/addons.conf".source = ./addons.conf;
        environment.etc."network/ifupdown2/ifupdown2.conf".source = ./ifupdown2.conf;

        environment.systemPackages = [ ifupdown2_pkg ];

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
              ${pkgs.coreutils-full}/bin/mkdir -p /run/network/
              ${ifupdown2_pkg}/bin/ifreload --all --debug --syntax-check
              ${ifupdown2_pkg}/bin/ifreload --all --debug
            '';
            RemainAfterExit = true;
          };
        };
      }
    );
}
