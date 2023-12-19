{ inputs
, pkgs
, ...
}:
{
  boot.plymouth = {
    enable = true;

    logo = "${inputs.nixos-artwork}/wallpapers/nix-wallpaper-watersplash.png";

    #themePackages = [ pkgs.catppuccin-plymouth ];
    #theme = "catppuccin-mocha";
  };
}
