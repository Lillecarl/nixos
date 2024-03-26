{ inputs, self, ... }:
let
  overrideModules = [
    {
      path = "modules/programs/carapace.nix";
      sha256 = "6c0d4fd2dfca6a9576c3ae97f71fa8718bd37d26431a3b06ee7658873bb7891f";
    }
  ];
  overrideModules_warnings = builtins.filter (mod: mod.sha256 != mod.modsha256) (builtins.map (mod: mod // { modsha256 = builtins.hashFile "sha256" "${inputs.home-manager}/${mod.path}"; }) overrideModules);
in
{
  warnings = builtins.map
    (mod: ''
      The module ${inputs.home-manager}/${mod.path} is overridden by ${self}/home-manager/${mod.path}
      Our specified sha256 is ${mod.sha256}, but the HM module sha256 is ${mod.modsha256} which means it's been modified since we snapshotted it
    '')
    overrideModules_warnings;
  imports = builtins.map (mod: "${self}/home-manager/${mod.path}") overrideModules;
  disabledModules = builtins.map (mod: "${inputs.home-manager}/${mod.path}") overrideModules;
}
