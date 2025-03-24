{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  modName = "default";
  cfg = config.ps.${modName};
in
{
  imports = [
    # ./default.nix
    ./acme.nix
    ./bluetooth.nix
    ./btrfs.nix
    ./command-not-found.nix
    ./dockerregistry.nix
    ./earlyoom.nix
    ./fail2ban.nix
    ./fish.nix
    ./guix.nix
    ./hardware-configuration.nix
    ./kea.nix
    ./libvirt.nix
    ./mosh.nix
    ./networking.nix
    ./niri.nix
    ./nix.nix
    ./noshell.nix
    ./openvpn.nix
    ./polkit.nix
    ./postgresql.nix
    ./remapper.nix
    ./samba.nix
    ./secrets.nix
    ./server.nix
    ./ssh.nix
    ./template.nix
    ./users.nix
    ./verycommon.nix
    ./waydroid.nix
    ./wireguard.nix
    ./workstation.nix
    ./xdg.nix
  ];

  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = true;
        description = "Whether to enable ${modName}.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Reference flake inputs in /etc. Prevents Nix collecting flake inputs as garbage.
    # I find it weird this isn't the default behaviour
    environment.etc = lib.mapAttrs' (key: val: {
      name = "flakeinputs/${key}";
      value = {
        source = "${val}";
      };
    }) inputs;

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      kernel.sysctl = {
        "kernel.task_delayacct" = 1;
      };
      tmp = {
        useTmpfs = true;
        tmpfsSize = "24G";
        cleanOnBoot = true;
      };
    };

    networking = {
      firewall = {
        rejectPackets = true;
        allowedTCPPorts = [
          80
          443
        ];
      };
      hosts = {
        "127.0.0.1" = [ "${config.networking.hostName}.lillecarl.com" ];
      };
    };

    # # Don't install the /lib/ld-linux.so.2 stub. This saves one instance of nixpkgs.
    environment.ldso32 = null;

    # Select internationalisation properties.
    # This adds 200MiB to system
    i18n = lib.mkIf false rec {
      defaultLocale = "en_DK.UTF-8";
      extraLocaleSettings = {
        LANG = defaultLocale;
        LC_ALL = defaultLocale;
        LC_TELEPHONE = "sv_SE.UTF-8";
      };
      supportedLocales = [ "all" ];
    };

    # Use us keymap
    console = {
      keyMap = "us";
    };

    programs = {
      # Bash autocomplete
      bash.completion.enable = true;
      # mtr w/o sudo
      mtr.enable = true;
      # Enable IO perf monitoring
      iotop.enable = true;
    };

    services = {
      # Configure timeservers
      ntp = {
        enable = true;
        servers = [
          "0.se.pool.ntp.org"
          "1.se.pool.ntp.org"
          "2.se.pool.ntp.org"
          "3.se.pool.ntp.org"
        ];
      };

      # Enable the OpenSSH daemon.
      openssh.enable = true;
    };

    security = {
      # Pluggable Authentication Modules (PAM)
      pam.loginLimits = [
        {
          # This fixes "ip vrf exec"
          domain = "*";
          item = "memlock"; # Locked memory, required for BPF programs
          type = "-"; # This is instead of hard/soft?
          value = 16384; # Value mentioned on RedHat bugzilla
        }
      ];

      sudo = {
        enable = true;
        extraConfig = ''
          Defaults insults
          Defaults pwfeedback
          Defaults:%wheel env_keep += "XDG_RUNTIME_DIR"
          Defaults:%wheel env_keep += "PATH"
        '';
        # Allow some commands superuser rights without password
        extraRules = [
          {
            # Allow running htop --readonly as sudoer without password
            users = [ "lillecarl" ];
            commands = [
              {
                command = "${lib.getExe pkgs.htop} --readonly";
                options = [ "NOPASSWD" ];
              }
              {
                command = "${lib.getExe pkgs.ddcutil}";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };
    };
  };
}
