{ lib
, ...
}: {
  programs.tealdeer = {
    enable = true;

    #updateOnActivation = true;

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
  # Don't update tealdeer cache on activation
  home.activation.tealdeerCache = lib.mkForce "echo Disabled";
}
