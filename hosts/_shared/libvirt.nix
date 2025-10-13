{
  self,
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  modName = "libvirt";
  cfg = config.ps.${modName};

  gamingvm = {
    uuid = "c3d5b031-1166-46c0-b86e-ec9f09bb550b";
    name = "win11-4";
    memory = 14336; # 14GiB
    threads = 2; # Better scheduling maybe?
    userUID = config.users.users.lillecarl.uid; # When running pipewire as lillecarl user rather than system-wide
    inherit lib pkgs;
  };
  gamingvmxml = pkgs.writeText "gamingvm.xml" (import "${self}/resources/gamingvm.xml.nix" gamingvm);

  networkxml = pkgs.writeText "network.xml" ''
    <network>
      <name>default</name>
      <uuid>a0d2739a-6dce-4c55-a2ae-90cd8820d39b</uuid>
      <forward mode='nat'/>
      <bridge name='virbr0' stp='on' delay='0'/>
      <mac address='52:54:00:0d:27:18'/>
      <ip address='192.168.122.1' netmask='255.255.255.0'>
        <dhcp>
          <range start='192.168.122.2' end='192.168.122.254'/>
        </dhcp>
      </ip>
    </network>
  '';
in
{
  # Imports virtualisation.libvirt (without d) options
  imports = [ inputs.nixvirt.nixosModules.default ];
  options.ps = {
    ${modName} = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable ${modName}.";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.etc."qemu/bridge.conf".text = "allow br0";
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;

          vhostUserPackages = [
            pkgs.virtiofsd
          ];
        };

        # Hook to (de)allocate hugepages for Windows gaming VM
        hooks.qemu =
          let
            hugepages = builtins.ceil (builtins.div gamingvm.memory 2);
            hugepagesWithOverhead = hugepages + 64; # 128MiB extra (64 pages) for eventual overhead
          in
          {
            ${gamingvm.name} =
              let
                awk = lib.getExe pkgs.gawk;
                fish = lib.getExe pkgs.fish;
                renice = "${pkgs.util-linux}/bin/renice";
                sponge = "${pkgs.moreutils}/bin/sponge";
                sysctl = lib.getExe pkgs.sysctl;
                systemctl = "${config.systemd.package}/bin/systemctl";
                virsh = "${pkgs.libvirt}/bin/virsh";
              in
              pkgs.writeScript "${gamingvm.name}-hook" # fish
                ''
                  #!${fish}
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
                  set vmpgid $(ps -o pgid --no-heading $vmpid | ${awk} '{print $1}')

                  if test $event = "prepare"
                    # Prepare kernel memory for gaming VM hugepages

                    # Minimize background memory compation
                    ${sysctl} -w vm.compation_proactiveness 1

                    # Drop filesystem caches
                    echo 3 | ${sponge} /proc/sys/vm/drop_caches

                    # Compact memory to make hugepages available
                    echo 1 | ${sponge} /proc/sys/vm/compact_memory

                    # Allocate 2M hugepages for vm (count = VM MiB / 2)
                    ${virsh} allocpages 2M ${toString hugepagesWithOverhead} || begin
                      echo Failed to allocate hugepages for ${gamingvm.name}
                      exit 1
                    end
                  else if test $event = "started"
                    # Renice VM to -1
                    ${renice} -1 -g $vmpgid

                    # Only schedule Linux stuff on CPU 5 and 11 (the 6th physical core)
                    ${systemctl} set-property --runtime -- init.scope AllowedCPUs=5,11
                    ${systemctl} set-property --runtime -- kubepods.scope AllowedCPUs=5,11
                    ${systemctl} set-property --runtime -- kubernetes.scope AllowedCPUs=5,11
                    ${systemctl} set-property --runtime -- system.slice AllowedCPUs=5,11
                    ${systemctl} set-property --runtime -- user.slice AllowedCPUs=5,11
                  else if test $event = "release"
                    # shutoff-reason is passed as fourth argument
                    set reason $argv[4]

                    # Release hugepages back to the system
                    ${virsh} allocpages 2M 0

                    # Reset scheduling back to use the entire CPU
                    ${systemctl} set-property --runtime -- init.scope AllowedCPUs=0-11
                    ${systemctl} set-property --runtime -- kubepods.scope AllowedCPUs=0-11
                    ${systemctl} set-property --runtime -- kubernetes.scope AllowedCPUs=0-11
                    ${systemctl} set-property --runtime -- system.slice AllowedCPUs=0-11
                    ${systemctl} set-property --runtime -- user.slice AllowedCPUs=0-11

                    # Enable background memory compation
                    ${sysctl} -w vm.compaction_proactiveness ${
                      builtins.toString config.boot.kernel.sysctl."vm.compaction_proactiveness"
                    }
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

    # Relink libvirt hooks when they change
    systemd.services.libvirtd-config.restartTriggers = lib.pipe config.virtualisation.libvirtd.hooks [
      (x: lib.attrValues x)
      (x: builtins.map (y: lib.attrValues y) x)
      (x: lib.flatten x)
    ];

    services.persistent-evdev = {
      enable = false;
      devices = {
        persist-vmdev = "vmdev";
      };
    };
    systemd.services.persistent-evdev = {
      serviceConfig = {
        Nice = -10;
      };
    };
  };
}
