# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  boot.initrd.availableKernelModules = [
    "vfio-pci"
    "amdgpu"
  ];
  boot.initrd.kernelModules = [ "amdgpu" "vfio-pci" ];
  boot.extraModprobeConfig = "options vfio-pci ids=10de:2487,10de:228b";
  boot.blacklistedKernelModules = [ "nvidiafb" "nouveau" "nvidia_drm" "nvidia" ];
  boot.kernelModules = [ "amdgpu" "kvm-amd" "wl" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" "i2c-dev" ];
  boot.kernelParams = [ "amd_iommu=on" "mitigations=off" "iommu=pt" "radeon.cik_support=0" "amdgpu.cik_support=1" ];

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

  fileSystems."/" =
    {
      device = "zroot/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "zroot/root/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "zroot/root/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/7774-7A15";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/706e9add-3b1c-49b4-94b0-795218b393ac"; }];

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = "performance";

  boot = {
    #kernelPackages = pkgs.linuxPackages_latest;
    # required for ZFS to build
    zfs.enableUnstable = true;
    # Enable ZFS boot
    supportedFilesystems = [ "zfs" ];
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    #initrd.availableKernelModules = [ "e1000e" "bcma" "r8169" ];
    initrd.network = {
      # This will use udhcp to get an ip address.
      # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`, 
      enable = true;
      ssh = {
        enable = true;
        # To prevent ssh from freaking out because a different host key is used,
        # use a different port for initrd SSH
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        # public ssh key used for login
        authorizedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJ8ga6UB6EPJAWaarh9vr852SKl5aEfNIoiwEeb7m36yDGLLxA/lw5ZzRH6i+krJYnTnXTUY7GVRxkBtPYsTF9tGN10jb7gvtZ67wuAl5Sxnt5EkXZuDS4M5ygT8zeBw0iM0k5/6ALNEaG+3UOT8gmFSqh5QxCqookA2XTDMPH8iZNFxhI5nhxTwkQu9iC7nOXVwg2VZsZJeh3VC823lrNZysuNYb9dGxE35atyjR8DPp83U7MfBZn2ppWGphoHfbCcH+w/oAHOiSr0iA7Kg8AuyeYh8KlbewNDSH7v/5GNzFsno+y5X2xPTNupP0FaL0gRkz/yvdyJcuWJw2UDujVm6frAxh7CKcWg7Tb6QZN/4dHnwpNu+XcffLTwQjMModM6olEJqdhzHyC7G5+fUQo4ngfN73MflwONYE+/verAgQRFv2d4kGHR3KTjW2duij8j1DScjv2s1VTYFUh9wC241xnH49Q9BHu5Rso/74jBDJ06uMU3bzoQoFZ3EMUJf8= lillecarl@nixos"
        ];
      };
      # this will automatically load the zfs password prompt on login
      # and kill the other prompt so boot can continue
      postCommands = ''
        echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
    };
  };

  # Networking, virbr0 is WAN iface
  networking = {
    hostName = "shitbox";
    hostId = "43211234";
    #useNetworkd = true;
    useDHCP = false;
    #nameservers = [ "1.1.1.1" ];
    #bridges.virbr0.interfaces = [ "eno1" ];
    #interfaces.eno1.useDHCP = false;
    #interfaces.virbr0.useDHCP = true;
    networkmanager = {
      enable = true;
      unmanaged = [ "virbr0" "lxdbr0" ];
    };
    firewall.enable = false;
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
    amdvlk
  ];
  hardware.opengl.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

  services = {
    xserver = {
      # Enable the Plasma 5 Desktop Environment.
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      # Keyboard layout
      layout = "us";
      # Use AMD driver
      videoDrivers = [ "amdgpu" ];
    };
    ratbagd = {
      enable = true;
    };
    zfs = {
      autoSnapshot = {
        enable = true;
        frequent = 8;
        monthly = 1;
      };
    };
    # Enable TOR
    tor = {
      enable = true;
      client = {
        enable = true;
      };
    };
    # Enable SSD trimming
    fstrim = {
      enable = true;
    };
    ntp = {
      enable = true;
      servers = [
        "0.se.pool.ntp.org"
        "1.se.pool.ntp.org"
        "2.se.pool.ntp.org"
        "3.se.pool.ntp.org"
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme # Lutris icons
    virt-manager # Virtualisation manager
    virt-manager-qt # Shitty version of virt-manager
    pciutils
    qemu_kvm
    dmidecode
    ksnip
    #tridactyl-native
    lshw
    bridge-utils
    qtcreator
    units
    heroku
    libreoffice
    piper
    syncthing
    nmap
    obs-studio
    gwenview
    okular
    virt-manager
    OVMFFull
    numactl
    looking-glass-client
    barrier
    etcher
    ark
    archiver
    libarchive
    discord
    teamspeak_client
    appimage-run # running appimages (shadow)

    # Hardware management
    smartmontools
    ddcutil # Monitor control
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      extraConfig = ''
        user="lillecarl"
      '';

      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd pkgs.OVMFFull ];
        };

        swtpm = {
          enable = true;
        };

        verbatimConfig = ''
          namespaces = []
          user = "+1000"
        '';
      };
    };
    lxd = {
      enable = true;
      zfsSupport = true;
      recommendedSysctlSettings = true;
    };
  };

  system.stateVersion = "20.09";
}

