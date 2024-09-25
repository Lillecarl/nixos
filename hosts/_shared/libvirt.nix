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
      hooks.qemu =
        let
          hugepages = builtins.ceil (builtins.div gamingvm.memory 2);
          hugepagesWithOverhead = hugepages + 64; # 128MiB extra
        in
        {
          ${gamingvm.name} = pkgs.writeScript "${gamingvm.name}-hook" /* fish */ ''
            #!${lib.getExe pkgs.fish}
            # See https://libvirt.org/hooks.html#etc-libvirt-hooks-qemu for hook documentation

            set vmname $argv[1] # vm name is passed as first argument
            set event $argv[2] # hooked event is passed as second argument

            # Only run this hook for gaming VM
            if test $vmname != ${gamingvm.name}
              exit 0
            end

            # Get the process id of the VM
            set vmpid $(cat /var/run/libvirt/qemu/$vmname.pid)
            # Get the process group id of the VM so we can renice all threads
            set vmpgid $(ps -o pgid --no-heading $vmpid | awk '{print $1}')

            if test $event = "prepare"
              # Prepare kernel memory for gaming VM hugepages

              # Drop filesystem caches
              echo 3 > /proc/sys/vm/drop_caches
              # Compact memory to make hugepages available
              echo 1 > /proc/sys/vm/compact_memory

              # Allocate 2M hugepages for vm (count = VM MiB / 2)
              virsh allocpages 2M ${toString hugepagesWithOverhead} || begin
                echo Failed to allocate hugepages for ${gamingvm.name}
                exit 1
              end
            else if test $event = "started"
              # Renice VM to -1
              renice -1 -g $vmpgid
            else if test $event = "release"
              # Release hugepages back to the system

              set reason $argv[4] # shutoff-reason is passed as fourth argument
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
