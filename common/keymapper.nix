{ pkgs, ... }:
{
  services.keymapper = {
    enable = true;
    extraArgs = [ "-v" ];
  };

  services.udev.extraRules =
    let
      coreutils = pkgs.coreutils-full;
    in
    ''
      # Link keymapper to named devices
      ACTION=="add", KERNEL=="event*", ATTRS{name}=="Keymapper", RUN+="${coreutils}/bin/ln -sf /dev/input/%k /dev/input/keymapper_kb"
      ACTION=="add", KERNEL=="mouse*", ATTRS{name}=="Keymapper", RUN+="${coreutils}/bin/ln -sf /dev/input/%k /dev/input/keymapper_mouse"
      ACTION=="remove", KERNEL=="event*", ATTRS{name}=="Keymapper", RUN+="${coreutils}/bin/unlink /dev/input/keymapper_kb"
      ACTION=="remove", KERNEL=="mouse*", ATTRS{name}=="Keymapper", RUN+="${coreutils}/bin/unlink /dev/input/keymapper_mouse"
    '';
}
