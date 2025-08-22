{
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.microvm.nixosModules.microvm
  ];
  config = {
    system.stateVersion = lib.trivial.release;
    services.getty.autologinUser = "root";

    hardware.graphics.enable = true;
    hardware.nvidia.open = true;

    programs.bash.shellInit = lib.mkAfter ''
      systemctl poweroff
    '';

    microvm = {
      # QEMU is the best of the bestest
      hypervisor = "qemu";

      # Minimal specs
      vcpu = 1;
      mem = 256;

      # Use host store
      storeOnDisk = false;
      shares = [
        {
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/store";
        }
      ];

      # Pass in NVIDIA GPU
      devices = [
        {
          bus = "pci";
          path = "0000:09:00.0";
        }
        {
          bus = "pci";
          path = "0000:09:00.1";
        }
      ];
    };
  };
}
