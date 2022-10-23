{ suites, config, lib, pkgs, modulesPath, ... }:
{
  imports = suites.nub;
  # Custom
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "22.05";
  # !Custom

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."1337".device = "/dev/disk/by-uuid/2bb21eac-b00e-4a9d-84f0-19d3c3d04dfe";

  fileSystems."/" =
    {
      device = "/dev/vg1/root";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/6F2C-B215";
      fsType = "vfat";
    };

  swapDevices = [{ device = "/dev/vg1/swap"; }];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
