{ pkgs
, config
, ...
}:
let
  firstUid = 1000;
in
{
  users = {
    enforceIdUniqueness = true;
    mutableUsers = false;

    users =
      let
        carl_base = uid: shell:
          {
            inherit uid shell;
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
              "wireshark"
              "i2c"
              "video"
              "pipewire"
              "uaccess"
              "uinput"
              "input"
              "kubernetes"
              "postgres"
            ];
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHZ3pA0vIXiKQuwfM1ks8TipeOxfDT9fgo4xMi9iiWr lillecarl@lillecarl.com"
            ];
            autoSubUidGidRange = true;
          };
      in
      {
        root = {
          linger = true;
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

        lillecarl = carl_base firstUid config.programs.noshell.package;
        bash = carl_base (firstUid + 1) pkgs.bash;
        qemu-libvirtd.extraGroups = [ "qemu-libvirt" "kvm" "input" "uinput" ];
      };
    groups = {
      uaccess = { };
    };
  };
}
