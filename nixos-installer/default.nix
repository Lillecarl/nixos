{ config
, pkgs
, lib
, inputs
, system
, ...
}:
{
  imports = [
    ../common/verycommon.nix
  ];

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.system}.default
  ];

  isoImage = {
    squashfsCompression = "zstd -Xcompression-level 6";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  system.stateVersion = "23.05";
}
