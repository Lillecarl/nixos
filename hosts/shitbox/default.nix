{
  pkgs,
  self,
  ...
}:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  disko.devices = import ./disko.nix {
    disk1 = "ata-SAMSUNG_MZ7LM1T9HMJP-00005_S2TVNX0J404544";
    disk2 = "ata-SAMSUNG_MZ7LM1T9HMJP-00005_S2TVNX0J404560";
  };

  system.activatableSystemBuilderCommands = ''
    ln -s ${self} $out/flake
  '';

  # Networking, virbr0 is WAN iface
  networking = {
    hostName = "shitbox";
    hostId = "43211234";
    useDHCP = false;
    networkmanager = {
      enable = true;
      unmanaged = [
        "virbr0"
        "lxdbr0"
      ];
    };
  };

  hardware.graphics.enable = true;

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  services = {
    ratbagd = {
      enable = true;
    };
    # Enable TOR
    tor = {
      enable = true;
      client = {
        enable = true;
      };
    };
    ntp = {
      enable = true;
      servers = [
        "0.se.pool.ntp.org"
        "1.se.pool.ntp.org"
        "2.se.pool.ntp.org"
        "3.se.pool.ntp.org"
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    virt-manager # Virtualisation manager
    pciutils
    qemu_kvm
    dmidecode
    ksnip
    lshw
    bridge-utils
    units
    piper
    nmap
    OVMFFull
    numactl
    looking-glass-client
    barrier
    libarchive
    discord

    # Hardware management
    smartmontools
    ddcutil # Monitor control
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
