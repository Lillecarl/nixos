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
    vim # Editor
    starship # Prompt
    zellij # Terminal multiplexer
    chezmoi # Dotfile manager
    gitui # Git TUI
    direnv # Env vars from directories
    kubectl # Kubernetes admin tool
    kubectx # Kubernetes session helper
    kubernetes-helm # Kubernetes package manager
    tldr # tldr manpages
    ripgrep # Nice grep
    powershell # scripting shell from MS
    cli53 # Route53 CLI
    unixtools.watch # watch command
    git-open # Open Git repos from cli in web
    git # VCS
    pijul # Cooler VCS
    tfswitch # Switch terraform versions
    asciinema # Record terminal sessions
    nodejs # Stupid language runtime
    nodePackages.npm # Stupid language package manager
    nodePackages.yarn # Stupid language less stupid package manager
    gource # VCS repo history visualizer
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
