_:
{
  programs.atuin = {
    enable = true;

    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "fuzzy";
      style = "compact";
      inline_height = 25;
      show_preview = true;
      invert = true;
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
