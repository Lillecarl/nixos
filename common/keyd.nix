{ ... }:
{
  #users.groups.keyd = { };
  services.keyd = {
    enable = true;

    keyboards = {
      default = {
        ids = [ "0001:0001" ];
        settings = {
          global = {
            default_layout = "us";
          };
          main = {
            include = "layouts/se";
            capslock = "overload(ctrl_vim, esc)";
            rightalt = "layer(swe_mode)";
            esc = "overload(swe_mode, esc)";
          };
          "ctrl_vim:C" = {
            space = "swap(vim_mode)";
            e = "setlayout(us)";
            s = "setlayout(se)";
          };
          "vim_mode:C" = {
            h = "left";
            j = "down";
            k = "up";
            l = "right";
            # forward word
            w = "C-right";
            # backward word
            b = "C-left";
          };
          swe_mode = {
            "[" = "macro(compose a  *)"; # å
            "'" = "macro(compose a \")"; # ä
            ";" = "macro(compose o \")"; # ö
          };
        };
      };
    };
  };
}
