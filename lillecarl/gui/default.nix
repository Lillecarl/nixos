{ pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./avizo.nix
    ./firefox.nix
    ./hyprland.nix
    ./mako.nix
    ./qutebrowser.nix
    ./sway.nix
    ./swaytools.nix
    ./vscode.nix
    ./waybar.nix
    ./wezterm.nix
  ];

  services.keymapper = {
    enable = true;

    extraConfig = ''
      CapsLock >> Control{Escape}
      Control{AltLeft{H}} >> ArrowLeft
      Control{AltLeft{L}} >> ArrowRight
      Control{AltLeft{K}} >> ArrowUp
      Control{AltLeft{J}} >> ArrowDown
    '';
  };

  home.packages = with pkgs; [
    # Web browsers
    pcmanfm

    # Terminal
    alacritty

    # gui neovim
    neovide

    dfeet # GUI browser for dbus

    # Media apps
    mpv # Media Player
    celluloid #  MPV GTK frontend wrapper
    vlc # VLC sucks in comparision to MPV

    wev # Like xev but for wayland, displays which keys you're pressing
    dfeet # D-Bus explorer
  ];

  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      input-overlay
      looking-glass-obs
      obs-backgroundremoval
      obs-gstreamer
      obs-vaapi
      obs-vkcapture
      wlrobs
    ];
  };
}
