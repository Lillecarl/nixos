{ lib
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
    extraModprobeConfig = ''
      options kvm_amd nested=1
      options thinkpad_acpi experimental=1 fan_control=1
    '';
    kernelParams = [
      "amd_pstate=guided"
      "iommu=soft"
      # Exposes all the available tunables to userspace as r/w rather than r/o.
      # https://community.frame.work/t/tracking-ppd-v-tlp-for-amd-ryzen-7040/39423/29
      "amdgpu.ppfeaturemask=0xffffffff"
      #"amd_pstate=active"
      #"amdgpu.ppfeaturemask=0xffffffff"
      #"amdgpu.sg_display=0"
      #"cpufreq.default_governor=powersave"
      #"initcall_blacklist=cpufreq_gov_userspace_init,cpufreq_gov_performance_init"
      #"pcie_aspm=force"
      #"pc"
      #"ie_aspm.policy=powersupersave"
    ];

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
