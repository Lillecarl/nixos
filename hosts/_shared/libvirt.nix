{ self, pkgs, lib, inputs, ... }:
let
  gamingvm = {
    uuid = "c3d5b031-1166-46c0-b86e-ec9f09bb550b";
    name = "win11-4";
    memory = 14336; # 14GiB
    vcpu = 10; # 10 out of 12 cores on shitbox
    threads = 2; # Better scheduling maybe?
  };
  gamingvmxml = pkgs.writeText "gamingvm.xml" (import "${self}/resources/gamingvm.xml.nix" gamingvm);
in
{
  # Imports virtualisation.libvirt (without d) options
  imports = [ inputs.nixvirt.nixosModules.default ];

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

      # Hook to (de)allocate hugepages for Windows gaming VM
      hooks.qemu = {
        ${gamingvm.name} = pkgs.writeScript "${gamingvm.name}-hook" /* fish */ ''
          #!${lib.getExe pkgs.fish}

          # Only run this hook for gaming VM
          if test $argv[1] != ${gamingvm.name}
            exit 0
          end

          # Prepare runs before the VM starts
          # Prepare kernel memory for gaming VM hugepages
          if test $argv[2] = "prepare"
            # Clear memory before starting vm
            echo 3 > /proc/sys/vm/drop_caches
            echo 1 > /proc/sys/vm/compact_memory

            # Allocate 2M hugepages for vm (count = VM MiB / 2)
            virsh allocpages 2M ${toString (builtins.ceil (builtins.div gamingvm.memory 2))} || begin
              echo Failed to allocate hugepages for ${gamingvm.name}
              exit 1
            end
          # Release runs after the VM stops and resources are cleared
          # Release hugepages back to the system
          else if test $argv[2] = "release"
            virsh allocpages 2M 0
          end
        '';
      };
    };

    # NixVirt https://github.com/AshleyYakeley/NixVirt
    libvirt = {
      enable = true;
      swtpm.enable = true;

      connections."qemu:///system" = {
        domains = [
          {
            definition = gamingvmxml;
            active = null;
            restart = false;
          }
        ];
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
