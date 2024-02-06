{ config
, inputs
, lib
, pkgs
, ...
}:
let
  cfg = config.carl.gui.wezterm;
in
{
  options.carl.gui.wezterm = with lib; {
    enable = lib.mkOption {
      type = types.bool;
      default = config.carl.gui.enable;
    };
  };
  config = lib.mkIf cfg.enable {
  programs.wezterm = {
    enable = false;

    package = pkgs.darwin.apple_sdk_11_0.callPackage ../../pkgs/tmp/wezterm.nix {
      inherit (pkgs.darwin.apple_sdk_11_0.frameworks) Cocoa CoreGraphics Foundation UserNotifications System;
      inherit inputs;
    };

    #systemdTarget = "hyprland-session.target";

    extraConfig = /* lua */ ''
      -- Indent fixer
          local nix_config = wezterm.config_builder()
          nix_config = {
            default_prog = { '${lib.getExe pkgs.fish}' },
          }
          for key, value in pairs(require('linked')) do
            nix_config[key] = value
          end

          return nix_config
    '';
  };
  };
}
