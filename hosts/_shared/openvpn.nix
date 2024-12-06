{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = [
    pkgs.openvpn
  ];

  systemd.services."openvpn-client@" = {
    enable = true;

    description = "OpenVPN tunnel for %I";
    after = [
      "syslog.target"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];

    documentation = [
      "man:openvpn(8)"
      "https://community.openvpn.net/openvpn/wiki/Openvpn24ManPage"
      "https://community.openvpn.net/openvpn/wiki/HOWTO"
    ];

    serviceConfig = {
      Type = "notify";
      PrivateTmp = "true";
      # Differs from official OpenVPN in that CWD is /etc/openvpn/client/%i rather than /etc/openvpn/client
      WorkingDirectory = "/etc/openvpn/client/%i";
      ExecStart = "${lib.getExe pkgs.openvpn} --suppress-timestamps --nobind --config %i.ovpn";
      CapabilityBoundingSet = "CAP_IPC_LOCK CAP_NET_ADMIN CAP_NET_RAW CAP_SETGID CAP_SETUID CAP_SYS_CHROOT CAP_DAC_OVERRIDE";
      LimitNPROC = 10;
      DeviceAllow = [
        "/dev/null rw"
        "/dev/net/tun rw"
      ];
      ProtectSystem = true;
      ProtectHome = true;
      KillMode = "process";
    };
  };

  # Create /etc/openvpn/client
  environment.etc = {
    "openvpn/client/README".text = ''
      Rather than storing your configurations in the root here, create a folder with the
      same name as the configuration file, makes it easier to store certificates without naming conflicts
    '';
    "openvpn/client/.keep".text = "";
  };
}
