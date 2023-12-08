{ pkgs
, inputs
, ...
}: {
  programs.wezterm = {
    enable = true;

    package = pkgs.darwin.apple_sdk_11_0.callPackage ../../pkgs/tmp/wezterm.nix {
      inherit (pkgs.darwin.apple_sdk_11_0.frameworks) Cocoa CoreGraphics Foundation UserNotifications System;
      inherit inputs;
    };

    #systemdTarget = "hyprland-session.target";

    extraConfig = ''
      -- Indent fixer
          local act = wezterm.action

          return {
            check_for_updates = false,
            window_close_confirmation = 'NeverPrompt',
            hide_mouse_cursor_when_typing = false,
            hide_tab_bar_if_only_one_tab = true,
            default_prog = { '${pkgs.fish}/bin/fish' },
            term = "wezterm",
            enable_wayland = true,
            set_environment_variables = {
              WSLENV = 'TERMINFO_DIRS',
            },
            keys = {--[[
              {
                key = "h",
                mods = "ALT",
                action = act.ActivatePaneDirection 'Left',
              },
              {
                key = "l",
                mods = "ALT",
                action = act.ActivatePaneDirection 'Right',
              },
              {
                key = "k",
                mods = "ALT",
                action = act.ActivatePaneDirection 'Up',
              },
              {
                key = "j",
                mods = "ALT",
                action = act.ActivatePaneDirection 'Down',
              },--]]
            },
          }
    '';
  };
}
