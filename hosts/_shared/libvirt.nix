{ pkgs, ... }:
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
