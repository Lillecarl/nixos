{
  disko.devices = {
    disk = {
      local = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 0;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zramWriteback = {
              priority = 1;
              size = "9G";
            };
            plainSwap = {
              priority = 2;
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                priority = 3; # 5 is default for zramSwap
              };
            };
          };
        };
      };
      remote = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:2";
        content = {
          type = "gpt";
          partitions = {
            primary = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "volumepool";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      volumepool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                # Subvolume name is different from mountpoint
                "/rootfs" = {
                  mountpoint = "/";
                };
                # Subvolume name is the same as the mountpoint
                "/home" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };
                # Parent is not mounted so the mountpoint must be set
                "/nix" = {
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
  };
}
