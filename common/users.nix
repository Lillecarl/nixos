{ pkgs
, ...
}:
rec {
  # Allow root to map to LilleCarl user in LXD container
  users.users.root = {
    subUidRanges = [
      {
        count = 1;
        startUid = users.users.lillecarl.uid;
      }
    ];
    subGidRanges = [
      {
        count = 1;
        startGid = 1000;
      }
    ];
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.lillecarl = {
    uid = 1000;
    #shell = "${pkgs.xonsh}/bin/xonsh";
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
    autoSubUidGidRange = true;
  };
}
