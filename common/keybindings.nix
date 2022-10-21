{ config, pkgs, ... }:
{
  services.actkbd = {
    enable = true;

    bindings = [
      {
        keys = [ 56 58 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.krunner /App org.kde.krunner.App.query \"window: \" &";
      }
      {
        keys = [ 57 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.krunner /App org.kde.krunner.App.query \"\" &";
      }
      {
        keys = [ 105 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Quick Tile Left\" &";
      }
      {
        keys = [ 106 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Quick Tile Right\" &";
      }
      {
        keys = [ 103 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Quick Tile Top\" &";
      }
      {
        keys = [ 108 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Quick Tile Bottom\" &";
      }
      {
        keys = [ 105 103 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Quick Tile Top Left\" &";
      }
      {
        keys = [ 106 103 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Quick Tile Top Right\" &";
      }
      {
        keys = [ 105 108 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Quick Tile Bottom Left\" &";
      }
      {
        keys = [ 106 108 125 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Quick Tile Bottom Right\" &";
      }
      {
        keys = [ 33 125 ];
        events = [ "key" ];
	attributes = [ "grab" ];
        command = "${pkgs.systemd}/bin/machinectl shell lillecarl@ /run/current-system/sw/bin/qdbus org.kde.kglobalaccel /component/kwin org.kde.kglobalaccel.Component.invokeShortcut \"Window Maximize\" &";
      }
      {
        keys = [ 33 125 ];
        events = [ "rel" ];
	attributes = [ "grabbed" "grab" "ungrab" "noexec" ];
      }
      {
        keys = [ 119 ];
	events = [ "key" ];
	command = "${pkgs.systemd}/bin/machinectl shell --setenv=WAYLAND_DISPLAY=wayland-0 --setenv=XDG_SESSION_TYPE=wayland lillecarl@ ${pkgs.spectacle}/bin/spectacle &";
      }
    ];
  };

}
