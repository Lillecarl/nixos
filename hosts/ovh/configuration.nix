{ self, lib, pkgs, config, modulesPath, ... }:
{
  imports = [
    ../_shared/users.nix
    ../_shared/nix.nix
    ../_shared/fish.nix
    "${self}/modules/nixos/ifupdown2"
  ];

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      ovmf = {
        enable = true;
      };

      swtpm = {
        enable = true;
      };

    };
  };


  boot.loader = {
    efi = {
      #canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
    grub = {
      enable = true;
      inherit (config.disko.devices.disk.one) device;
      efiSupport = true;
      copyKernels = true;
      devices = lib.mkForce [ "nodev" ];
      mirroredBoots = [
        {
          devices = [ config.disko.devices.disk.two.device ];
          path = "/boot";
          efiSysMountPoint = "/boot/efi2";
        }
      ];
    };
  };

  time.timeZone = "Europe/Stockholm";
  services.openssh.enable = true;
  system.stateVersion = "23.11";
}
