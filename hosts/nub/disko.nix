{ disk, ... }:
{
  disko.devices.disk = {
    "disk1" = {
      device = "/dev/disk/by-id/${disk}";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            type = "EF02";
            start = "0";
            end = "1MiB";
          };
          esp = {
            start = "1MiB";
            type = "EF00";
            end = "1GiB";
            label = "ESP";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "sync"
              ];
            };
          };
          root = {
            start = "1GiB";
            end = "100%";
            label = "root";
            content = {
              type = "luks";
              name = "crypted";
              extraOpenArgs = [ "--allow-discards" ];
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
              "/tmp" = {
                mountOptions = [ "compress=zstd:1" "noatime" ];
                mountpoint = "/tmp";
              };
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
