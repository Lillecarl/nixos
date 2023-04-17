{ config, pkgs, inputs, ... }:
let
  icons = ''
    [aws]
    symbol = "  "
    
    [buf]
    symbol = " "
    
    [c]
    symbol = " "
    
    [conda]
    symbol = " "
    
    [dart]
    symbol = " "
    
    [directory]
    read_only = " "
    
    [docker_context]
    symbol = " "
    
    [elixir]
    symbol = " "
    
    [elm]
    symbol = " "
    
    [fossil_branch]
    symbol = " "
    
    [git_branch]
    symbol = " "
    
    [golang]
    symbol = " "
    
    [guix_shell]
    symbol = " "
    
    [haskell]
    symbol = " "
    
    [haxe]
    symbol = "⌘ "
    
    [hg_branch]
    symbol = " "
    
    [java]
    symbol = " "
    
    [julia]
    symbol = " "
    
    [lua]
    symbol = " "
    
    [memory_usage]
    symbol = " "
    
    [meson]
    symbol = "喝 "
    
    [nim]
    symbol = " "
    
    [nix_shell]
    symbol = " "
    
    [nodejs]
    symbol = " "
    
    [os.symbols]
    Alpine = " "
    Amazon = " "
    Android = " "
    Arch = " "
    CentOS = " "
    Debian = " "
    DragonFly = " "
    Emscripten = " "
    EndeavourOS = " "
    Fedora = " "
    FreeBSD = " "
    Garuda = "﯑ "
    Gentoo = " "
    HardenedBSD = "ﲊ "
    Illumos = " "
    Linux = " "
    Macos = " "
    Manjaro = " "
    Mariner = " "
    MidnightBSD = " "
    Mint = " "
    NetBSD = " "
    NixOS = " "
    OpenBSD = " "
    openSUSE = " "
    OracleLinux = " "
    Pop = " "
    Raspbian = " "
    Redhat = " "
    RedHatEnterprise = " "
    Redox = " "
    Solus = "ﴱ "
    SUSE = " "
    Ubuntu = " "
    Unknown = " "
    Windows = " "
    
    [package]
    symbol = " "
    
    [pijul_channel]
    symbol = "🪺 "
    
    [python]
    symbol = " "
    
    [rlang]
    symbol = "ﳒ "
    
    [ruby]
    symbol = " "
    
    [rust]
    symbol = " "
    
    [scala]
    symbol = " "
    
    [spack]
    symbol = "🅢 "
  '';
in
{
  programs.starship = {
    enable = true;

    settings = builtins.fromTOML icons // {
      # We don't use terraform workspaces so don't consume the space
      terraform = {
        disabled = true;
      };

      # Directory config, truncation_length is subpath count not char count
      # don't truncate to git repo (not sure how i feel about this one yet)
      directory = {
        truncate_to_repo = false;
        truncation_length = 10;
      };

      # Show exit codes
      status = {
        disabled = false;
      };

      username = {
        format = "[$user]($style) on";
      };

      time = {
        disabled = false;
      };

      kubernetes = {
        disabled = false;
      };

      sudo = {
        disabled = false;
      };

      # Display which shell we're in
      # Do we actually need this? We use xonsh all the time.
      env_var.STARSHIP_SHELL = {
        format = "🐚 [$env_value]($style) ";
        style = "fg:green";
      };
    };
  };
}
