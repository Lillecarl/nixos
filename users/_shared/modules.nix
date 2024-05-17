{ self, inputs, ... }:
{
  imports = [
    (self + "/stylix.nix")
    inputs.agenix.homeManagerModules.default
    #inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.stylix.homeManagerModules.stylix
    inputs.catppuccin-nix.homeManagerModules.catppuccin
  ];
}
