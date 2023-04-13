# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [
    "vfio-pci"
    "amdgpu"
  ];
  boot.kernelPackages = with pkgs.linuxKernel.packages; linux_5_15;
  #boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
  boot.initrd.kernelModules = [ "amdgpu" "vfio-pci" ];
  boot.extraModprobeConfig = "options vfio-pci ids=10de:2487,10de:228b";
  boot.kernelModules = [
    "drivetemp"
    "nct6775"
    "amdgpu"
    "kvm-amd"
    "wl"
    "vfio_virqfd"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
  ];
  boot.kernelParams = [
    "amd_iommu=on"
    "mitigations=off"
    "iommu=pt"
    # Something something HAWAII maybe?
    "radeon.si_support=0"
    "radeon.cik_support=0"
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
    "acpi_enforce_resources=lax"
  ];

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

  #boot.extraModulePackages = with config.boot.kernelPackages; [
  #  usbip
  #];

  boot.postBootCommands = ''
    ${pkgs.kmod}/bin/modprobe -r nvidiafb
    ${pkgs.kmod}/bin/modprobe -r nouveau

    echo 0 > /sys/class/vtconsole/vtcon0/bind
    echo 0 > /sys/class/vtconsole/vtcon1/bind
    echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

    DEVS="0000:08:00.0 0000:08:00.1"
  
    for DEV in $DEVS; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    ${pkgs.kmod}/bin/modprobe -i vfio-pci
  '';

  boot.kernel.sysctl = {
    "vm.swappiness" = 1;
  };

  hardware.enableAllFirmware = true;
  hardware.i2c.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "performance";
}
