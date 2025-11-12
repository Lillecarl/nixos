{
  lib,
  pkgs,
  self,
  inputs,
  ...
}:
{
  imports = [
    inputs.microvm.nixosModules.host
    ./amdmicrocode.nix
    ./audiovideo.nix
    ./facter.nix
    ./hardware-configuration.nix
    ./home-assistant.nix
    ./k3s.nix
    ./spotifyd.nix
    ./syncthing.nix
    ./wireguard.nix
    ./initrd.nix
    ./networking.nix
    ./kubeadm.nix
  ];
  microvm = {
    autostart = [ ];
  };
  programs.nix-ld.enable = true;
  programs.adb.enable = true;
  programs.ssh.extraConfig = # ssh
    ''
      Host 192.168.88.20
        Port 2222
        User nix
        IdentityFile /etc/lillecarl/ed25519-local
        HostKeyAlias nix-csi-builder
        StrictHostKeyChecking accept-new
      Host *.nix-builders
        HostName %h
        User nix
        IdentityFile /etc/lillecarl/ed25519-local
        ProxyJump 192.168.88.20
        HostKeyAlias nix-csi-builder
        StrictHostKeyChecking accept-new

      Host nixbuild.lillecarl.com
        Port 2222
        User nix
        IdentityFile /etc/lillecarl/ed25519-hetzkube
        HostKeyAlias hetzkube
        StrictHostKeyChecking accept-new
      Host *.hetzkube
        HostName %h
        User nix
        IdentityFile /etc/lillecarl/ed25519-hetzkube
        ProxyJump nixbuild.lillecarl.com
        HostKeyAlias hetzkube
        StrictHostKeyChecking accept-new

      # nixbuild
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile /etc/nixbuild
        KexAlgorithms diffie-hellman-group1-sha1,diffie-hellman-group14-sha1,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha1,diffie-hellman-group-exchange-sha256,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,curve25519-sha256,curve25519-sha256@libssh.org,sntrup761x25519-sha512,sntrup761x25519-sha512@openssh.com,mlkem768x25519-sha256
    '';

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

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
    libarchive

    # Hardware management
    smartmontools
    ddcutil # Monitor control
  ];
  systemd.services.mdmonitor.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
