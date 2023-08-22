{ pkgs
, ...
}:
let
  firstUid = 1000;
in
{
  users = {
    defaultUserShell = pkgs.zsh;
    enforceIdUniqueness = true;
    mutableUsers = false;

    users = {
      root = {
        subUidRanges = [
          {
            count = 1;
            startUid = firstUid;
          }
        ];
        subGidRanges = [
          {
            count = 1;
            startGid = 1000;
          }
        ];
      };

      lillecarl = {
        uid = firstUid;
        hashedPassword = "$y$j9T$U4zBBS9RMV9YMttHauO8k0$V.KT/P/AdBTXXT8f6p9EIlCsZV5UnaPDgEVtUvUJU3C";
        createHome = true;
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "libvirtd"
          "networkmanager"
          "lxd"
          "flatpak"
          "adbusers"
          "podman"
          "wireshark"
          "i2c"
          "video"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHZ3pA0vIXiKQuwfM1ks8TipeOxfDT9fgo4xMi9iiWr lillecarl@lillecarl.com"
        ];
        autoSubUidGidRange = true;
      };
    };
  };
}