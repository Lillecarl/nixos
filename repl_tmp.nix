{ lib, ... }@ctx:
{
  hyprscroller = lib.elemAt ctx.home.config.wayland.windowManager.hyprland.plugins 0;
  hyprland = ctx.home.config.wayland.windowManager.hyprland.package;
}
