allArgs:
{
  services.keymapper = {
    enable = allArgs.systemConfig.services.keymapper.enable or false;

    extraConfig = ''
      # Virtual1 layer
      [modifier="Virtual1"]
      # Leave Virtual1 layer with Escape, CapsLock or Pause
      Escape >> Virtual1{Any}
      CapsLock >> Escape Virtual1{Any}
      Pause >> Virtual1{Any}

      # Remap F12 to b for testing purposes
      F12 >> B
      # Remap qwe to 123
      #       asd    456
      #       zxc    789
      Q >> 1
      W >> 2
      E >> 3
      A >> 4
      S >> 5
      D >> 6
      Z >> 7
      X >> 8
      C >> 9

      # "Default layer" (There aren't really any layers)
      [default]
      Shift   >> Shift
      Control >> Control
      AltLeft >> AltLeft

      # ctrl + alt + hjkl = arrow keys
      Control{AltLeft{H}} >> ArrowLeft
      Control{AltLeft{L}} >> ArrowRight
      Control{AltLeft{K}} >> ArrowUp
      Control{AltLeft{J}} >> ArrowDown

      # If we're holding down caps we want ctrl
      CapsLock{200ms} >> Control
      # Otherwise map caps to esc
      CapsLock >> Escape

      # Entering and leaving Virtual1 layer with pause key
      Pause >> Virtual1{Any}
      Virtual1 >> Virtual1{Any}

      Control{AltLeft{H}} >> ArrowLeft
      Control{AltLeft{L}} >> ArrowRight
      Control{AltLeft{K}} >> ArrowUp
      Control{AltLeft{J}} >> ArrowDown
      CapsLock{250ms} >> Control
      CapsLock >> Escape

      # Enter Virtual1 layer by pressing Pause, leave with Pause
      Pause >> Virtual1{Any}

      [modifier="Virtual1"]
      Escape >> Virtual1{Any}
      F12 >> B
    '';
  };
}
