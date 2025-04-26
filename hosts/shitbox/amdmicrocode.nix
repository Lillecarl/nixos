{ inputs, ... }:
{
  imports = [ inputs.ucodenix.nixosModules.default ];
  config = {
    boot.kernelParams = [ "microcode.amd_sha_check=off" ];

    services.ucodenix = {
      enable = true;
      cpuModelId = ./facter.json;
    };
  };
}
