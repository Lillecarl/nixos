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
    vim
    starship
    zellij
    chezmoi
    gitui
    direnv
    kubectl
    kubectx
    kubernetes-helm
    tldr
    ripgrep
    powershell
    cli53
    unixtools.watch
    git-open
    git
    pijul
    ## Packages below are broken in Nix and installed with brew
    #brave
    #slack
    #wezterm
    #iterm2
  ];

  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
}
