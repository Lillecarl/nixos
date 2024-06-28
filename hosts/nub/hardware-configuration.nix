{ lib
, pkgs
, ...
}:
{
  services.udev.extraHwdb = ''
    # thinkpad_acpi driver
    evdev:name:ThinkPad Extra Buttons:dmi:bvn*:bvr*:bd*:svnLENOVO*:pn*:*
     KEYBOARD_KEY_1a=micmute
  '';

  services.xserver.xkb.extraLayouts.lenovo = {
    description = "Doing a multi billion dollar company's job for them";
    languages = [ "US" "swe" ];
    keycodesFile = pkgs.writeText "lenovo-keycodes" ''
            partial xkb_keycodes "lenovo" {
      	      <I248> = 248;
            }
    '';
    symbolsFile = pkgs.writeText "lenovo-symbols" ''
      partial xkb_symbols "lenovo" {
        key <I248> { [ XF86AudioMicMute ] };
      }
    '';
  };


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
    graphics.enable = true;
    cpu.amd.updateMicrocode = true;
  };
}
