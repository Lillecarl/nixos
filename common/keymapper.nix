{ pkgs
, config
, ...
}:
{
  services.keymapper = {
    enable = true;
    extraArgs = [ "-v" ];
  };

  services.udev.extraRules =
    let
      coreutils = pkgs.coreutils-full;
    in
    ''
      # Link keymapper to named devices
      ACTION=="add", KERNEL=="event*", ATTRS{name}=="Keymapper", RUN+="${coreutils}/bin/ln -sf /dev/input/%k /dev/input/keymapper_kb"
      ACTION=="add", KERNEL=="mouse*", ATTRS{name}=="Keymapper", RUN+="${coreutils}/bin/ln -sf /dev/input/%k /dev/input/keymapper_mouse"
      ACTION=="remove", KERNEL=="event*", ATTRS{name}=="Keymapper", RUN+="${coreutils}/bin/unlink /dev/input/keymapper_kb"
      ACTION=="remove", KERNEL=="mouse*", ATTRS{name}=="Keymapper", RUN+="${coreutils}/bin/unlink /dev/input/keymapper_mouse"
    '';

  # Found that keymapperd can get stuck in a loop and eat up CPU
  systemd = {
    timers.keymapper-mon = {
      enable = true;
      wantedBy = [ "keymapper.service" ];

      timerConfig = {
        OnCalendar = "*-*-* *:*:00";
        AccuracySec = "60";
        Persistent = true;
      };

    };

    services.keymapper-mon = {
      enable = true;
      wantedBy = [ "keymapper.service" ];

      path = [
        config.systemd.package
        pkgs.procps
        pkgs.bc
        pkgs.coreutils
        pkgs.gawk
      ];

      script = ''
        cpu=$(ps -p $(pgrep keymapperd) -u --no-headers | awk '{ print $3 }' | bc)
        if test $cpu -gt 10; then
          systemctl restart keymapperd
        fi
      '';
    };
    services.keymapper-restart = {
      enable = true;
      wantedBy = [ "post-resume.target" ];

      path = [
        config.systemd.package
      ];

      script = ''
        systemctl restart keymapper
      '';
    };
  };
}
