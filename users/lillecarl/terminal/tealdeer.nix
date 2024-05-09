_: {
  programs.tealdeer = {
    enable = true;

    settings = {
      display = {
        compact = false;
        use_pager = false;
      };

      updates = {
        auto_update = true;
        auto_update_interval_hours = 168;
      };
    };
  };
}