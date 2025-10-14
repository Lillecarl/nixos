{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    initrd.kernelModules = [
      "i915"
      "vfio-pci"
    ];
    extraModprobeConfig = ''
      options vfio-pci ids=10de:2487,10de:228b
      options kvm ignore_msrs=1 report_ignored_msrs=0

      # Force GPU modules to load after VFIO (?)
      softdep amdgpu pre: vfio_pci
      softdep i915 pre: vfio_pci
      softdep nvidia pre: vfio_pci
    '';
    blacklistedKernelModules = [
      "radeon"
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
    ];
    kernelModules = [
      "i915"
      "kvm-amd"
      "vfio_virqfd"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
      "dm_thin_pool"
      "dm_snapshot"
    ];
    kernelParams = [
      "i915.enable_guc=2"
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

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Required for Arc GPUs
      intel-vaapi-driver # Fallback
    ];
  };

  services.udev.extraRules = # udev
    ''
      # Use kyber IO scheduler
      ACTION=="add|change", SUBSYSTEM=="block", ATTR{queue/scheduler}=="*kyber*", ATTR{queue/scheduler}="kyber"
      # Disable USB wake for SINOWEALTH gaming mouse
      SUBSYSTEM=="usb", ATTRS{idVendor}=="258a", ATTRS{idProduct}=="0033", ATTR{power/wakeup}="disabled"
    '';

  services.lvm.boot.thin.enable = true;

  hardware = {
    enableAllFirmware = true;
    i2c.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  powerManagement.cpuFreqGovernor = "performance";
}
