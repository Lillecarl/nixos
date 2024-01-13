{ ... }:
{
  programs.atuin = {
    enable = true;

    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "prefix";
      style = "compact";
      inline_height = 25;
      show_preview = true;
      invert = true;
    };
  };
}
