{ config, pkgs, lib, ... }:
{
  # These tools are common across MacOS and Linux
  environment.systemPackages = with pkgs; [
    vim # Editor
    starship # Prompt
    mcfly # Improved history search
    zellij # Terminal multiplexer
    chezmoi # Dotfile manager
    gitui # Git TUI
    direnv # Env vars from directories
    #vmctl # Cert-manager CLI
    kubectl # Kubernetes admin tool
    kubectx # Kubernetes session helper
    kubernetes-helm # Kubernetes package manager
    kustomize # Kubernetes YAML configurations
    octant # Kubernetes GUI
    rancher # Rancher CLI
    tldr # tldr manpages
    cheat # tldr alternative
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
    jq # JSON CLI Tool
    yq # YAML CLI Tool
    jless # JSON TUI browser
    thefuck # Command fixing tool
  ];

}
