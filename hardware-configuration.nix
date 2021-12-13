# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

rec {
  imports = [
    (
      modulesPath + "/installer/scan/not-detected.nix"
    )
  ];

  services.tlp = {
    enable = true;
    settings = {
      "CPU_SCALING_GOVENOR_ON_AC" = "powersave";
      "CPU_SCALING_GOVENOR_ON_BAT" = "powersave";
      "START_CHARGE_THRESH_BAT0" = 75;
      "STOP_CHARGE_THRESH_BAT0" = 80;
    };
  };
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "powersave";
    powerUpCommands = ''
      (sleep 5; systemctl start powerTune.service) &
    '';
    powerDownCommands = ''
      $(pkgs.coreutils)/bin/sync
      echo 1 > /proc/sys/vm/drop_caches
    '';
  };

  services.thermald.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware = {
    cpu = {
      intel = {
        updateMicrocode = true;
      };
    };
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for FF/Chromium)
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # Enables all System76 Firmware
    system76.enableAll = lib.mkDefault true;
    # Enables binary blobs
    enableRedistributableFirmware = true;
    # Enables bluetooth
    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
      # This enables a2dp-sink, which is HQ audio w/o mic. (Needed for pairing WH-1000XM3)
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };

  #security = {
  #  tpm = {
  #    enable = true;
  #    abrmd.enable = true;
  #  };
  #};

  boot = {
    # boot with grub rather than systemd-boot because we want mirrored bootloaders
    # set EFI variables to look for kernels where we want (NVRAM), disabled since we install as removeable
    # must set this to true and disable efiInstallAsRemovable to do system76 firmware updates
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = true;
      # We use GPT and our boot partitions are FAT32
      # nodev means don't install MBR bogus on early blocks
      device = "nodev";
      efiSupport = true;
      # Not sure if needed, TODO research
      enableCryptodisk = true;
      # should already be implicit
      copyKernels = true;
      # efi standard makes sure we boot from these even if NVRAM dies or we fail to update it
      # https://search.nixos.org/options?show=boot.loader.grub.efiInstallAsRemovable&type=packages&query=efi
      #efiInstallAsRemovable = true;
      mirroredBoots = [
        #{
        #  "devices" = [ "nodev" ];
        #  "path" = "/boot";
        #  "efiSysMountPoint" = "/boot";
        #}
        {
          "devices" = [ "nodev" ];
          "path" = "/boot-fallback";
          "efiSysMountPoint" = "/boot-fallback";
        }
      ];
    };

    # Plymouth, shows a splash screen rather than systemd boot sequence
    # since our system boots to bloody fast this is barely noticeable
    #plymouth.enable = true;

    # initrd = initial ramdisk.
    initrd = {
      # RAID configuration, can be exported with "sudo mdadm --scan --export" 
      mdadmConf = ''
        ARRAY /dev/md/1337 level=raid1 num-devices=2 metadata=1.2 name=nixos:1337 UUID=aec75f01:8035340e:0689cd7a:7e344342
           devices=/dev/nvme0n1p2,/dev/nvme1n1p2
      '';

      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
      kernelModules = [ ];
      # Decrypt our mdadm data RAID parition (/dev/md/1337p2)
      luks.devices."crypt0".device = "/dev/disk/by-uuid/7932002d-70fe-4966-abec-6a679a5ebd91";
      luks.devices."crypt0".fallbackToPassword = true;
    };

    #kernelPackages = pkgs.linuxPackages_5_14;
    #kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
      evdi
      akvcam
      cryptodev
      cpupower
      turbostat
      x86_energy_perf_policy
      system76
      system76-io
      system76-acpi
    ];
    # udl was here, which is the old displaylink driver
    kernelModules = [ "evdi" "kvm-intel" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    kernelParams = [ "intel_iommu=on" ];

    kernelPatches = [
      {
        name = "s76_1";
        patch = builtins.fetchurl {
          url = "https://github.com/torvalds/linux/commit/95563d45b5da9cdd07496bf54f0d83f25d679847.patch";
          sha256 = "0b3b8bdam9d3hba34pfdqsd932f76v18hawg6jr1gj3iy1z64fdi";
        };
      }
      {
        name = "s76_2";
        patch = builtins.fetchurl {
          url = "https://github.com/torvalds/linux/commit/0de30fc684b3883be73602b7557661951319a9b9.patch";
          sha256 = "0kwmxm4qxcbs0s30n791df50kkiphnwp6wis95j0dsfmsf9ilw0l";
        };
      }
      {
        name = "s76_3";
        patch = builtins.fetchurl {
          url = "https://github.com/torvalds/linux/commit/76f7eba3e0a248af4cc4f302d95031fa2fb65fab.patch";
          sha256 = "0d4gcgjswy3g89asi7d2hhk2gsgzw6f6dvjzsbr6516arr5gvjaq";
        };
      }
      {
        name = "s76_4";
        patch = builtins.fetchurl {
          url = "https://github.com/torvalds/linux/commit/603a7dd08f881e1b5c754429dac5af6c29992528.patch";
          sha256 = "1lf4g40ijp7kjns1z2cqkwzfd2nb6yf71003d5hvbapy3av5151a";
        };
      }
      {
        name = "s76_5";
        patch = builtins.fetchurl {
          url = "https://github.com/torvalds/linux/commit/97ae45953ea957887170078f488fd629dd1ce786.patch";
          sha256 = "0rk60ab2qwirnrw936mbnvzilqkdm9rxs854hcm6x5sp2c135bhg";
        };
      }
    ];
  };

  # Root BTRFS filesystem, let's hope ZFS implements support for hibernation soon!
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a48a0b28-4f7f-4b20-b52e-a4f69ae636c7";
    fsType = "btrfs";
  };

  # Primary bootloader
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B0B5-42A2";
    fsType = "vfat";
    # Write to disk "as soon as reasonable"
    # seems to be required to not fuck the bootloader (using a sync script atm)
    options = [ "defaults" "flush" ];
  };

  # Secondary bootloader
  fileSystems."/boot-fallback" = {
    device = "/dev/disk/by-uuid/1D41-D24F";
    fsType = "vfat";
    # Write to disk "as soon as reasonable"
    # seems to be required to not fuck the bootloader (using a sync script atm)
    options = [ "defaults" "flush" ];
  };

  # Swap device, this is raided
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/83f469d8-1da6-47b4-a808-204ca591ce28";
    }
  ];
}
