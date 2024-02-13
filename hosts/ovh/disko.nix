{ lib, disk1 ? "vda", disk2 ? "vdb", ... }:
let
  disk = (name: {
    type = "disk";
    device = "/dev/${name}";
    content = {
      type = "gpt";
      partitions = {
        BOOT = {
          size = "1M";
          type = "EF02"; # for grub MBR
        };
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = if name == "vda" then "/boot/efi" else "/boot2/efi";
            mountOptions = [
              "sync"
            ];
          };
        };
        boot = {
          size = "512M";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = if name == "vda" then "/boot" else "/boot2";
            mountOptions = [
              "sync"
            ];
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
in
{
  disko.devices.disk.${disk1} = disk disk1;
  disko.devices.disk.${disk2} = disk disk2;
  disko.devices.mdadm = {
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
  disko.devices.lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        nixos = {
          size = "14G";
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
          size = "2G";
          content = {
            type = "swap";
          };
        };
      };
    };
  };
}
