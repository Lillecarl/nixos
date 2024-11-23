{ lib, config, ... }:
{
  programs.atuin = lib.mkIf config.ps.terminal.enable {
    enable = true;

    flags = [
      "--disable-up-arrow"
      "--disable-ctrl-r"
    ];

    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 25;
      show_preview = true;
      invert = true;
      filter_mode_shell_up_key_binding = "session";
      stats = {
        common_subcommands = [
          "cargo"
          "go"
          "git"
          "npm"
          "yarn"
          "pnpm"
          "kubectl"
          "systemctl"
          "journalctl"
        ];
        common_prefix = [
          "sudo"
        ];
      };
    };
  };
}
