{ config
, lib
, pkgs
, extraPackages ? [ ]
, ...
}:
with lib; let
  cfg = config.networking.ifupdown2;
in
{
  options = {
    networking.ifupdown2 = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
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
            pkgs.iptables
            pkgs.kmod
            pkgs.mstpd
            pkgs.openvswitch
            pkgs.ppp
            pkgs.procps
            pkgs.pstree
            pkgs.service-wrapper
            pkgs.systemd
            pkgs.iptables
          ]
        '';
        description = ''
          Set of packages to add to $PATH of ifreload/ifup/ifdown.
        '';
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          /etc/network/interfaces configuration
          See https://cumulusnetworks.github.io/ifupdown2/ifupdown2/userguide.html#configuration-files
        '';
      };
    };
  };

  config =
    mkIf cfg.enable
      (
        let
          ifupdown2_pkg = pkgs.ifupdown2.overrideAttrs (final: prev: {
            propagatedBuildInputs = prev.propagatedBuildInputs ++ cfg.extraPackages;
          });
        in
        {
          environment.etc."network/interfaces".text = lib.mkDefault cfg.extraConfig;
          environment.etc."network/ifupdown2/addons.conf".text = lib.mkDefault (builtins.readFile "${ifupdown2_pkg.src}/etc/network/ifupdown2/addons.conf");
          environment.etc."network/ifupdown2/ifupdown2.conf".text = lib.mkDefault (builtins.readFile "${ifupdown2_pkg.src}/etc/network/ifupdown2/ifupdown2.conf");

          environment.etc."iproute2/.keep".text = "";
          environment.etc."iproute2/policy.d/.keep".text = "";
          environment.etc."iproute2/rt_tables.d/.keep".text = "";
          environment.etc."ppp/.keep".text = "";

          environment.systemPackages = [ ifupdown2_pkg ];

          systemd.services.ifupdown2 = {
            wantedBy = [ "network.target" ];
            wants = [ "network.target" ];
            before = [ "network-online.target" ];
            restartTriggers = [
              config.environment.etc."network/interfaces".source
              config.environment.etc."network/ifupdown2/addons.conf".source
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
