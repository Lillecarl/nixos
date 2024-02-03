{ inputs, self, ... }:
let
  overrideModules = [
    {
      path = "modules/programs/fish.nix";
      sha256 = "cb8ee07361d4b14f80c48568e5d009eb21706264f54b8f6de2b333fb6ce30213";
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
