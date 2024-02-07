{ lib, pkgs, config, modulesPath, ... }:
{
  networking = {
    hostName = "ovh"; # System hostname
    usedDHCP = true;
  };

  disko.devices = import ./disko.nix {
    disk1 = "nvme-INTEL_SSDPE2MX450G7_CVPF72160068450RGN";
    disk2 = "nvme-INTEL_SSDPE2MX450G7_BTPF80720AN6450RGN";
  }; 

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
    grub = {
      enable = true;
      device = "/dev/sda";
      efiSupport = true;
      copyKernels = true;
      mirroredBoots = [
        {
          devices = [ "/dev/sdb" ];
          path = "/boot2";
          efiSysMountPoint = "/boot2/efi";
        }
      ];
    };
  };

  system.stateVersion = "23.05";
}
#total 0
#drwxr-xr-x 2 root root 200 Dec  4 03:16 .
#drwxr-xr-x 7 root root 140 Dec  4 03:16 ..
#lrwxrwxrwx 1 root root  13 Dec  4 03:16 nvme-INTEL_SSDPE2MX450G7_BTPF80720AN6450RGN -> ../../nvme1n1
#lrwxrwxrwx 1 root root  13 Dec  4 03:16 nvme-INTEL_SSDPE2MX450G7_BTPF80720AN6450RGN_1 -> ../../nvme1n1
#lrwxrwxrwx 1 root root  13 Dec  4 03:16 nvme-INTEL_SSDPE2MX450G7_CVPF72160068450RGN -> ../../nvme0n1
#lrwxrwxrwx 1 root root  13 Dec  4 03:16 nvme-INTEL_SSDPE2MX450G7_CVPF72160068450RGN_1 -> ../../nvme0n1
#lrwxrwxrwx 1 root root  13 Dec  4 03:16 nvme-nvme.8086-425450463830373230414e3634353052474e-494e54454c205353445045324d583435304737-00000001 -> ../../nvme1n1
#lrwxrwxrwx 1 root root  13 Dec  4 03:16 nvme-nvme.8086-43565046373231363030363834353052474e-494e54454c205353445045324d583435304737-00000001 -> ../../nvme0n1
#lrwxrwxrwx 1 root root   9 Dec  4 03:16 usb-Virtual_CDROM_serial-0:0 -> ../../sr0
#lrwxrwxrwx 1 root root   9 Dec  4 03:16 usb-Virtual_Floppy_serial-0:1 -> ../../sda
