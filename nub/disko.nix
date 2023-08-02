{ disk ? "nvme0n1", ... }:
{
  disko.devices.disk = {
    ${disk} = {
      device = "/dev/${disk}";
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "MBR";
            start = "0";
            end = "1MiB";
            bootable = true;
            flags = [ "bios_grub" ];
          }
          {
            name = "ESP";
            start = "1MiB";
            end = "1GiB";
            bootable = true;
            fs-type = "fat32";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "sync"
              ];
            };
          }
          {
            name = "root";
            start = "1GiB";
            end = "100%";
            part-type = "primary";
            content = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [ "--allow-discards" ];
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
  disko.devices.lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        nixos = {
          size = "230G";
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
              "/tmp" = { };
            };
          };
        };
        swap = {
          size = "14G";
          content = {
            type = "swap";
          };
        };
      };
    };
  };
}
