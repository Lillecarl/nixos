{ disk1, disk2, ... }:
let
  samedisk =
    {
      disk,
      index,
    }:
    let
      idx = toString index;
    in
    {
      device = "/dev/disk/by-id/${disk}";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          mbr = {
            start = "0";
            end = "1MiB";
            type = "EF02";
          };
          ESP = {
            label = "ESP${idx}";
            start = "1MiB";
            end = "1GiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot${idx}/efi";
              mountOptions = [
                "sync"
              ];
            };
          };
          boot = {
            label = "boot${idx}";
            start = "1GiB";
            end = "2GiB";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot${idx}";
              mountOptions = [
                "defaults"
                "sync"
              ];
            };
          };
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
    # 1GiB boot, rest mdraid
    "disk1" = samedisk {
      disk = disk1;
      index = "";
    };
    "disk2" = samedisk {
      disk = disk2;
      index = 2;
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
