{ disk1, disk2, ... }:
let
  samedisk =
    { disk
    , bootloc
    ,
    }: {
      device = "${disk}";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          mbr = {
            size = "1M";
            type = "EF02"; # for grub MBR
          };
          ESP = {
            start = "1M";
            end = "1GiB";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/${bootloc}/efi";
              mountOptions = [
                "sync"
              ];
            };
          };
          boot = {
            start = "1G";
            end = "2G";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/${bootloc}";
              mountOptions = [
                "defaults"
                "sync"
              ];
            };
          };
          mdadm = {
            start = "2G";
            end = "100%";
            content = {
              type = "mdraid";
              name = "raid1";
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
      bootloc = "boot";
    };
    "disk2" = samedisk {
      disk = disk2;
      bootloc = "boot2";
    };
  };
  mdadm = {
    raid1 = {
      type = "mdadm";
      level = 1;
      content = {
        type = "luks";
        name = "crypted";
        content = {
          type = "lvm_pv";
          vg = "pool";
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
        swap = {
          size = "32G";
          content = {
            type = "swap";
          };
        };
      };
    };
  };
}
