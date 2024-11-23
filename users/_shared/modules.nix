{ self, inputs, ... }:
{
  imports = [
    (self + "/stylix.nix")
    inputs.agenix.homeManagerModules.default
    inputs.stylix.homeManagerModules.stylix
    inputs.catppuccin-nix.homeManagerModules.catppuccin
  ];
}
