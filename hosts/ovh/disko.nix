{ lib, disk1, disk2, ... }:
{
  disko.devices.disk = lib.genAttrs [ "a" "b" ] (name: {
    type = "disk";
    device = "/dev/sd${name}";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02"; # for grub MBR
        };
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "mdraid";
            name = "boot";
          };
        };
        mdadm = {
          size = "100%";
          content = {
            type = "mdraid";
            name = "raid1";
          };
        };
      };
    };
  });
  disko.devices.mdadm = {
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
