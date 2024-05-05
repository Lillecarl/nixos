{ self, inputs, ... }:
{
  imports = [
    (self + "/stylix.nix")
    inputs.agenix.homeManagerModules.default
    inputs.niri.homeModules.niri
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.stylix.homeManagerModules.stylix
    inputs.nix-snapshotter.homeModules.default
    inputs.catppuccin-nix.homeManagerModules.catppuccin
  ];
}
