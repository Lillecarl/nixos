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
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "0MiB";
            end = "1GiB";
            bootable = true;
            fs-type = "fat32";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/${bootloc}/efi";
              mountOptions = [
                "sync"
              ];
            };
          }
          {
            name = "boot";
            start = "1GiB";
            end = "2GiB";
            bootable = false;
            fs-type = "ext4";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/${bootloc}";
              mountOptions = [
                "defaults"
                "sync"
              ];
            };
          }
          {
            name = "root";
            start = "2GiB";
            end = "100%";
            part-type = "primary";
            content = {
              type = "mdraid";
              name = "root";
            };
          }
        ];
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
    root = {
      type = "mdadm";
      level = 1;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "primary";
            start = "1MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "crypted";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          }
        ];
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
