{ config
, ...
}:
{
  boot = {
    initrd.availableKernelModules = [
      "vfio-pci"
    ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    #kernelPackages = pkgs.linuxPackages_latest;
    #kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
    initrd.kernelModules = [ "vfio-pci" ];
    extraModprobeConfig = ''
      options vfio-pci ids=10de:2487,10de:228b
      blacklist nouveau
      options nouveau modeset=0
    '';
    blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
    kernelModules = [
      "drivetemp"
      "nct6775"
      "kvm-amd"
      "wl"
      "vfio_virqfd"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
    ];
    kernelParams = [
      "nohibernate"
      "amd_iommu=on"
      "mitigations=off"
      "iommu=pt"
      "acpi_enforce_resources=lax"
      "delayacct"
    ];

    extraModulePackages = with config.boot.kernelPackages; [
      zfs
      v4l2loopback.out
      usbip
      zenpower
      turbostat
      cpupower
    ];

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
      };
      grub = {
        enable = true;
        device = config.disko.devices.disk.disk1.device;
        efiSupport = true;
        copyKernels = true;
        mirroredBoots = [
          {
            devices = [ config.disko.devices.disk.disk2.device ];
            path = "/boot2";
            efiSysMountPoint = "/boot2/efi";
          }
        ];
      };
    };

    kernel.sysctl = {
      "vm.swappiness" = 1;
    };
  };

  hardware = {
    enableAllFirmware = true;
    i2c.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  powerManagement.cpuFreqGovernor = "performance";
}
