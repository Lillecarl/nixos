{ disk1, disk2, ... }:
let
  samedisk =
    {
      disk,
    }:
    {
      device = "/dev/disk/by-id/${disk}";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          root = {
            label = "root";
            start = "2GiB";
            end = "100%";
            content = {
              type = "mdraid";
              name = "root";
            };
          };
        };
      };
    };
in
{
  disk = {
    main = {
      type = "disk";
      device = "/dev/disk/by-id/usb-Samsung_Flash_Drive_FIT_0375425030006570-0:0";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            size = "10G";
            type = "EF00";
            label = "USBEFI";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "umask=0077"
              ];
            };
          };
        };
      };
    };
    "disk1" = samedisk {
      disk = disk1;
    };
    "disk2" = samedisk {
      disk = disk2;
    };
  };
  mdadm = {
    root = {
      type = "mdadm";
      level = 1;
      content = {
        type = "gpt";
        partitions = {
          primary = {
            start = "1MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "crypted";
              settings.allowDiscards = true;
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };
  };
  lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        nixos = {
          size = "250G";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            #mountpoint = "/";
            mountOptions = [
              "defaults"
              "discard=async"
              "ssd"
              "space_cache=v2"
              "lazytime"
            ];
            subvolumes = {
              # Subvolume name is different from mountpoint
              "rootfs" = {
                mountpoint = "/";
              };
              # Mountpoints inferred from subvolume name
              "/home" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/home";
              };
              "/nix" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                mountpoint = "/nix";
              };
              "/var" = {
                mountpoint = "/var";
              };
              "/srv" = {
                mountpoint = "/srv";
              };
              #"/tmp" = {
              #  mountpoint = "/tmp";
              #};
            };
          };
        };
        windows = {
          size = "250G";
        };
        swap = {
          size = "32G";
          content = {
            type = "swap";
            priority = 25;
            discardPolicy = "both";
          };
        };
        zram-writeback = {
          size = "16G";
        };
      };
    };
  };
}
