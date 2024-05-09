_:
{
  disko.devices = {
    disk = {
      one = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            #mbr = {
            #  start = "0";
            #  end = "1MiB";
            #  type = "EF02";
            #};
            ESP = {
              label = "ESP1";
              start = "1MiB";
              end = "1GiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [
                  "sync"
                ];
              };
            };
            boot = {
              size = "500M";
              type = "EF00";
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            primary = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
      two = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            #mbr = {
            #  start = "0";
            #  end = "1MiB";
            #  type = "EF02";
            #};
            ESP = {
              label = "ESP2";
              start = "1MiB";
              end = "1GiB";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi2";
                mountOptions = [
                  "sync"
                ];
              };
            };
            boot = {
              size = "500M";
              type = "EF00";
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            primary = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };
    mdadm = {
      boot = {
        type = "mdadm";
        level = 1;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "25G";
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
                  mountOptions = [ "compress=zstd" "noatime" ];
                  mountpoint = "/nix";
                };
                "/var" = { };
                "/srv" = { };
                "/tmp" = {
                  mountOptions = [ "compress=zstd:1" "noatime" ];
                  mountpoint = "/tmp";
                };
              };
            };
          };
        };
      };
    };
  };
}
