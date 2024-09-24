{ pkgs, lib, inputs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd pkgs.OVMFFull ];
        };

        swtpm.enable = true;

        vhostUserPackages = [
          pkgs.virtiofsd
        ];
      };

      hooks.qemu = {
        # Hook to (de)allocate hugepages for win11-4 Windows gaming VM
        win11-4 = pkgs.writeScript "win11-4-hook" /* fish */ ''
          #!${lib.getExe pkgs.fish}

          # Only run this hook for win11-4 VM
          if test $argv[1] != "win11-4"
            exit 0
          end

          if test $argv[2] = "prepare"
            # Clear memory before starting win11-4
            echo 3 > /proc/sys/vm/drop_caches
            echo 1 > /proc/sys/vm/compact_memory
            sleep 1 # To let the memory be compacted(?)
            virsh allocpages 2M 8192 || begin
              echo "Failed to allocate hugepages for win11-4"
              exit 1
            end
          else if test $argv[2] = "release"
            virsh allocpages 2M 0
          end
        '';
      };
    };
  };

  services.persistent-evdev = {
    enable = true;
    devices = {
      persist-vmdev = "vmdev";
    };
  };
  systemd.services.persistent-evdev = {
    serviceConfig = {
      Nice = -10;
    };
  };
}
