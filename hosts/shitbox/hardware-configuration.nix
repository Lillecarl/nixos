{ config
, pkgs
, ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "amdgpu"
      "vfio-pci"
    ];
    initrd.kernelModules = [
      "amdgpu"
      "vfio-pci"
    ];
    extraModprobeConfig = ''
      options vfio-pci ids=10de:2487,10de:228b
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';
    blacklistedKernelModules = [
      "radeon"
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
    ];
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
      "acpi_enforce_resources=lax"
      "amd_iommu=on"
      "hugepages=8192"
      "iommu=pt"
      "kvm.ignore_msrs=1"
      "mitigations=off"
      "nohibernate"
      "vfio_iommu_type1.allow_unsafe_interrupts=1"
    ];

    extraModulePackages = with config.boot.kernelPackages; [
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
        enableCryptodisk = true;
        inherit (config.disko.devices.disk.disk1) device;
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
      "vm.hugetlb_shm_group" = 0;
      "kernel.shmmax" = 17179869184;
    };
  };

  hardware = {
    enableAllFirmware = true;
    i2c.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  powerManagement.cpuFreqGovernor = "performance";
}
