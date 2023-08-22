{ lib
, config
, ...
}:
{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "thinkpad_acpi"
  ];
  boot.initrd.systemd.enable = true;

  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.extraModprobeConfig = "options kvm_amd nested=1";

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    configurationLimit = 15;
    pkiBundle = "/etc/secureboot";
  };

  hardware.opengl = {
    driSupport32Bit = false;
  };

  hardware.cpu.amd.updateMicrocode = true;
}
