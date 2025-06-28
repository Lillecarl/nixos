{ config, pkgs, ... }:
{
  boot.initrd = {
    availableKernelModules = [ "igc" ];
    extraUtilsCommands = # bash
      ''
        copy_bin_and_libs ${
          pkgs.writeScriptBin "unlock" # bash
            ''
              #! /bin/sh
              cryptsetup open /dev/md127p1 crypted
            ''
        }/bin/unlock
      '';
    network = {
      enable = true;
      flushBeforeStage2 = true;
      udhcpc = {
        enable = true;
        extraArgs = [
          "-x hostname:${config.networking.hostName}-boot"
        ];
      };
      ssh = {
        enable = true;
        port = 2222;
        authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
        hostKeys = [
          "/boot/ssh/ed25519"
          "/boot/ssh/rsa"
        ];
      };
    };
  };
}
