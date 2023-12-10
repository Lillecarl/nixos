{ lib
, config
, ...
}:
{
  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
      ];

      kernelModules = [
        "dm-snapshot"
        "thinkpad_acpi"
      ];
      systemd.enable = true;
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    extraModprobeConfig = "options kvm_amd nested=1";
    kernelParams = [ "amd_pstate=guided" "iommu=soft" ];

    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      configurationLimit = 15;
      pkiBundle = "/etc/secureboot";
    };
  };

  hardware = {
    opengl = {
      driSupport32Bit = false;
    };

    cpu.amd.updateMicrocode = true;
  };
}
