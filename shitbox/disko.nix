{ ... }:
let
  disk1 = "sda";
  disk2 = "sdb";

  samedisk = { disk, bootloc }: {
    device = "/dev/${disk}";
    type = "disk";
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "boot";
          type = "partition";
          start = "0";
          end = "1MiB";
          bootable = true;
          flags = [ "bios_grub" ];
        }
        {
          type = "partition";
          name = "ESP";
          start = "1MiB";
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
          type = "partition";
          name = "ESP";
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
          type = "partition";
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
    "${disk1}" = samedisk { disk = disk1; bootloc = "boot"; };
    "${disk2}" = samedisk { disk = disk2; bootloc = "boot2"; };
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
            type = "partition";
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
          type = "lvm_lv";
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
              };
              "/nix" = {
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "/var" = { };
              "/srv" = { };
              "/tmp" = { };
            };
          };
        };
        windows = {
          type = "lvm_lv";
          size = "250G";
        };
        swap = {
          type = "lvm_lv";
          size = "32G";
          content = {
            type = "swap";
          };
        };
      };
    };
  };
}
