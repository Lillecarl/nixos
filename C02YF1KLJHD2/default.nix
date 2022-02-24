{ pkgs, ... }:
{
  nixpkgs = {
    # Allow proprietary software to be installed
    config.allowUnfree = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ 
    starship
  ];

  programs.zsh.enable = true;
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
}
