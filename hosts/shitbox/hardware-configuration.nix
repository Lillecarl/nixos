{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages;
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
      "dm_thin_pool"
      "dm_snapshot"
    ];
    kernelParams = [
      "acpi_enforce_resources=lax"
      "amd_iommu=on"
      "iommu=pt"
      "kvm.ignore_msrs=1"
      "mitigations=off"
      "nohibernate"
      "vfio_iommu_type1.allow_unsafe_interrupts=1"
    ];

    extraModulePackages = with config.boot.kernelPackages; [
      usbip
      turbostat
      cpupower
    ];

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot"; # ← use the same mount point here.
      };
      grub = {
        enable = true;
        enableCryptodisk = true;
        device = "nodev";
        efiSupport = true;
        copyKernels = true;
      };
    };
  };

  services.udev.extraRules = # udev
    ''
      ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/scheduler}=="*kyber*", ATTR{queue/scheduler}="kyber"
    '';

  services.lvm.boot.thin.enable = true;

  hardware = {
    enableAllFirmware = true;
    i2c.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  powerManagement.cpuFreqGovernor = "performance";
}
