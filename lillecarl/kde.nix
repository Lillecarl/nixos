{
  programs.plasma = {
    enable = true;
    workspace.clickItemTo = "select";

    shortcuts = {
      # Launch WezTerm
      "org.wezfurlong.wezterm.desktop"."_launch" = "Meta+Return";

      # KB Layout Switching
      "KDE Keyboard Layout Switcher"."Switch keyboard layout to English (US)" = "Alt+Shift+U";
      "KDE Keyboard Layout Switcher"."Switch keyboard layout to Swedish" = "Alt+Shift+S";

      "kaccess"."Toggle Screen Reader On and Off" = [ ];
      "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
      "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
      "kcm_touchpad"."Toggle Touchpad" = [ "Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku" ];
      "kded5"."Show System Activity" = "Ctrl+Esc";
      "kded5"."display" = [ "Meta+P" "Display" ];
      "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
      "kmix"."decrease_volume" = "Volume Down";
      "kmix"."increase_microphone_volume" = "Microphone Volume Up";
      "kmix"."increase_volume" = "Volume Up";
      "kmix"."mic_mute" = [ "Microphone Mute" "Meta+Volume Mute" ];
      "kmix"."mute" = "Volume Mute";
      "ksmserver"."Halt Without Confirmation" = [ ];
      "ksmserver"."Lock Session" = [ "Screensaver" "Ctrl+Alt+Del" ];
      "ksmserver"."Log Out" = [ ];
      "ksmserver"."Log Out Without Confirmation" = [ ];
      "ksmserver"."Reboot Without Confirmation" = [ ];
      "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
      "kwin"."Decrease Opacity" = [ ];
      "kwin"."Expose" = "Ctrl+F9";
      "kwin"."ExposeAll" = [ "Ctrl+F10" "Launch (C)" ];
      "kwin"."ExposeClass" = "Ctrl+F7";
      "kwin"."ExposeClassCurrentDesktop" = [ ];
      "kwin"."Increase Opacity" = [ ];
      "kwin"."Invert Screen Colors" = [ ];
      "kwin"."Kill Window" = "Meta+Ctrl+Esc";
      "kwin"."MoveMouseToCenter" = "Meta+F6";
      "kwin"."MoveMouseToFocus" = "Meta+F5";
      "kwin"."MoveZoomDown" = [ ];
      "kwin"."MoveZoomLeft" = [ ];
      "kwin"."MoveZoomRight" = [ ];
      "kwin"."MoveZoomUp" = [ ];
      "kwin"."Overview" = "Meta+W";
      "kwin"."Setup Window Shortcut" = [ ];
      "kwin"."Show Desktop" = "Meta+D";
      "kwin"."ShowDesktopGrid" = "Meta+F8";
      "kwin"."Suspend Compositing" = "Alt+Shift+F12";
      "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down";
      "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up";
      "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
      "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
      "kwin"."Switch Window Down" = "Meta+Alt+Down";
      "kwin"."Switch Window Left" = "Meta+Alt+Left";
      "kwin"."Switch Window Right" = "Meta+Alt+Right";
      "kwin"."Switch Window Up" = "Meta+Alt+Up";
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";
      "kwin"."Switch to Desktop 5" = "Meta+5";
      "kwin"."Switch to Desktop 6" = "Meta+6";
      "kwin"."Switch to Desktop 7" = "Meta+7";
      "kwin"."Switch to Desktop 8" = "Meta+8";
      "kwin"."Switch to Desktop 9" = [ ];
      "kwin"."Switch to Desktop 10" = [ ];
      "kwin"."Switch to Desktop 11" = [ ];
      "kwin"."Switch to Desktop 12" = [ ];
      "kwin"."Switch to Desktop 13" = [ ];
      "kwin"."Switch to Desktop 14" = [ ];
      "kwin"."Switch to Desktop 15" = [ ];
      "kwin"."Switch to Desktop 16" = [ ];
      "kwin"."Switch to Desktop 17" = [ ];
      "kwin"."Switch to Desktop 18" = [ ];
      "kwin"."Switch to Desktop 19" = [ ];
      "kwin"."Switch to Desktop 20" = [ ];
      "kwin"."Switch to Next Desktop" = [ ];
      "kwin"."Switch to Next Screen" = [ ];
      "kwin"."Switch to Previous Desktop" = [ ];
      "kwin"."Switch to Previous Screen" = [ ];
      "kwin"."Switch to Screen 0" = [ ];
      "kwin"."Switch to Screen 1" = [ ];
      "kwin"."Switch to Screen 2" = [ ];
      "kwin"."Switch to Screen 3" = [ ];
      "kwin"."Switch to Screen 4" = [ ];
      "kwin"."Switch to Screen 5" = [ ];
      "kwin"."Switch to Screen 6" = [ ];
      "kwin"."Switch to Screen 7" = [ ];
      "kwin"."Toggle" = [ ];
      "kwin"."Toggle Night Color" = [ ];
      "kwin"."Toggle Window Raise/Lower" = [ ];
      "kwin"."Walk Through Desktop List" = [ ];
      "kwin"."Walk Through Desktop List (Reverse)" = [ ];
      "kwin"."Walk Through Desktops" = [ ];
      "kwin"."Walk Through Desktops (Reverse)" = [ ];
      "kwin"."Walk Through Windows" = "Alt+Tab";
      "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Backtab";
      "kwin"."Walk Through Windows Alternative" = [ ];
      "kwin"."Walk Through Windows Alternative (Reverse)" = [ ];
      "kwin"."Walk Through Windows of Current Application" = "Alt+`";
      "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
      "kwin"."Walk Through Windows of Current Application Alternative" = [ ];
      "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = [ ];
      "kwin"."Window Above Other Windows" = [ ];
      "kwin"."Window Below Other Windows" = [ ];
      "kwin"."Window Close" = [ "Alt+F4" "Alt+Q" ];
      "kwin"."Window Fullscreen" = [ ];
      "kwin"."Window Grow Horizontal" = [ ];
      "kwin"."Window Grow Vertical" = [ ];
      "kwin"."Window Lower" = [ ];
      "kwin"."Window Maximize" = [ "Meta+M" ];
      "kwin"."Window Maximize Horizontal" = [ ];
      "kwin"."Window Maximize Vertical" = [ ];
      "kwin"."Window Minimize" = [ ];
      "kwin"."Window Move" = [ ];
      "kwin"."Window Move Center" = [ ];
      "kwin"."Window No Border" = [ ];
      "kwin"."Window On All Desktops" = [ ];
      "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
      "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
      "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
      "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
      "kwin"."Window Operations Menu" = "Alt+F3";
      "kwin"."Window Pack Down" = [ ];
      "kwin"."Window Pack Left" = [ ];
      "kwin"."Window Pack Right" = [ ];
      "kwin"."Window Pack Up" = [ ];
      "kwin"."Window Quick Tile Top" = [ "Meta+K" "Meta+Up" ];
      "kwin"."Window Quick Tile Bottom" = [ "Meta+J" "Meta+Down" ];
      "kwin"."Window Quick Tile Left" = [ "Meta+H" "Meta+Left" ];
      "kwin"."Window Quick Tile Right" = [ "Meta+L" "Meta+Right" ];
      "kwin"."Window Quick Tile Bottom Left" = [ ];
      "kwin"."Window Quick Tile Bottom Right" = [ ];
      "kwin"."Window Quick Tile Top Left" = [ ];
      "kwin"."Window Quick Tile Top Right" = [ ];
      "kwin"."Window Raise" = [ ];
      "kwin"."Window Resize" = [ ];
      "kwin"."Window Shade" = [ ];
      "kwin"."Window Shrink Horizontal" = [ ];
      "kwin"."Window Shrink Vertical" = [ ];
      "kwin"."Window to Desktop 1" = "Alt+1";
      "kwin"."Window to Desktop 2" = "Alt+2";
      "kwin"."Window to Desktop 3" = "Alt+3";
      "kwin"."Window to Desktop 4" = "Alt+4";
      "kwin"."Window to Desktop 5" = "Alt+5";
      "kwin"."Window to Desktop 6" = "Alt+6";
      "kwin"."Window to Desktop 7" = "Alt+7";
      "kwin"."Window to Desktop 8" = "Alt+8";
      "kwin"."Window to Desktop 9" = [ ];
      "kwin"."Window to Desktop 10" = [ ];
      "kwin"."Window to Desktop 11" = [ ];
      "kwin"."Window to Desktop 12" = [ ];
      "kwin"."Window to Desktop 13" = [ ];
      "kwin"."Window to Desktop 14" = [ ];
      "kwin"."Window to Desktop 15" = [ ];
      "kwin"."Window to Desktop 16" = [ ];
      "kwin"."Window to Desktop 17" = [ ];
      "kwin"."Window to Desktop 18" = [ ];
      "kwin"."Window to Desktop 19" = [ ];
      "kwin"."Window to Desktop 20" = [ ];
      "kwin"."Window to Next Desktop" = [ ];
      "kwin"."Window to Next Screen" = [ "Meta+PgDown" "Meta+PgUp" ];
      "kwin"."Window to Previous Desktop" = [ ];
      "kwin"."Window to Previous Screen" = [ ];
      "kwin"."Window to Screen %1" = [ ];
      "kwin"."Window to Screen 0" = [ ];
      "kwin"."Window to Screen 1" = [ ];
      "kwin"."Window to Screen 2" = [ ];
      "kwin"."Window to Screen 3" = [ ];
      "kwin"."Window to Screen 4" = [ ];
      "kwin"."Window to Screen 5" = [ ];
      "kwin"."Window to Screen 6" = [ ];
      "kwin"."Window to Screen 7" = [ ];
      "kwin"."WindowGeometry" = [ ];
      "kwin"."view_actual_size" = [ ];
      "kwin"."view_zoom_in" = "Meta++";
      "kwin"."view_zoom_out" = "Meta+-";
      "mediacontrol"."mediavolumedown" = [ ];
      "mediacontrol"."mediavolumeup" = [ ];
      "mediacontrol"."nextmedia" = "Media Next";
      "mediacontrol"."pausemedia" = "Media Pause";
      "mediacontrol"."playmedia" = [ ];
      "mediacontrol"."playpausemedia" = "Media Play";
      "mediacontrol"."previousmedia" = "Media Previous";
      "mediacontrol"."stopmedia" = "Media Stop";
      "org.kde.dolphin.desktop"."_launch" = "Meta+E";
      "org.kde.krunner.desktop"."RunClipboard" = [ ];
      "org.kde.krunner.desktop"."_launch" = [ "Alt+Space" "Search" ];
      "org.kde.plasma.emojier.desktop"."_launch" = "Meta+.";
      "org.kde.spectacle.desktop"."ActiveWindowScreenShot" = "Meta+Print";
      "org.kde.spectacle.desktop"."CurrentMonitorScreenShot" = [ ];
      "org.kde.spectacle.desktop"."FullScreenScreenShot" = "Shift+Print";
      "org.kde.spectacle.desktop"."OpenWithoutScreenshot" = [ ];
      "org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Meta+Shift+Print";
      "org.kde.spectacle.desktop"."WindowUnderCursorScreenShot" = "Meta+Ctrl+Print";
      "org.kde.spectacle.desktop"."_launch" = "Print";
      "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
      "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
      "org_kde_powerdevil"."Hibernate" = "Hibernate";
      "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
      "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
      "org_kde_powerdevil"."PowerDown" = "Power Down";
      "org_kde_powerdevil"."PowerOff" = "Power Off";
      "org_kde_powerdevil"."Sleep" = "Sleep";
      "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
      "org_kde_powerdevil"."Turn Off Screen" = [ ];
      "plasmashell"."activate task manager entry 1" = [ ];
      "plasmashell"."activate task manager entry 2" = [ ];
      "plasmashell"."activate task manager entry 3" = [ ];
      "plasmashell"."activate task manager entry 4" = [ ];
      "plasmashell"."activate task manager entry 5" = [ ];
      "plasmashell"."activate task manager entry 6" = [ ];
      "plasmashell"."activate task manager entry 7" = [ ];
      "plasmashell"."activate task manager entry 8" = [ ];
      "plasmashell"."activate task manager entry 9" = [ ];
      "plasmashell"."activate task manager entry 10" = [ ];
      "plasmashell"."clear-history" = [ ];
      "plasmashell"."clipboard_action" = [ ];
      "plasmashell"."cycle-panels" = [ ];
      "plasmashell"."cycleNextAction" = [ ];
      "plasmashell"."cyclePrevAction" = [ ];
      "plasmashell"."edit_clipboard" = [ ];
      "plasmashell"."manage activities" = [ ];
      "plasmashell"."next activity" = "Meta+Tab";
      "plasmashell"."previous activity" = "Meta+Shift+Tab";
      "plasmashell"."repeat_action" = [ ];
      "plasmashell"."show dashboard" = [ ];
      "plasmashell"."show-barcode" = [ ];
      "plasmashell"."show-on-mouse-pos" = [ "Meta+V" "Ctrl+Alt+V" ];
      "plasmashell"."stop current activity" = [ ];
      "plasmashell"."switch to next activity" = [ ];
      "plasmashell"."switch to previous activity" = [ ];
      "plasmashell"."toggle do not disturb" = [ ];
      "systemsettings.desktop"."_launch" = "Tools";
      "systemsettings.desktop"."kcm-kscreen" = [ ];
      "systemsettings.desktop"."kcm-lookandfeel" = [ ];
      "systemsettings.desktop"."kcm-users" = [ ];
      "systemsettings.desktop"."powerdevilprofilesconfig" = [ ];
      "systemsettings.desktop"."screenlocker" = [ ];
    };
    files = {
      #Bismuth
      "kglobalshortcutsrc"."bismuth"."_k_friendly_name" = "Window Tiling";
      "kwinrc"."Plugins"."bismuthEnabled" = true;
      "kwinrc"."Script-bismuth"."noTileBorder" = true;

      # KDE Virtual Desktops
      "kwinrc"."Desktops"."Id_1" = "0f94886f-7893-4742-ace2-4de80d493919";
      "kwinrc"."Desktops"."Id_2" = "6d034b2d-396c-4a15-8ed2-d5cf13d14ba8";
      "kwinrc"."Desktops"."Id_3" = "5c5bba19-6ab3-46a1-952a-67963c19c206";
      "kwinrc"."Desktops"."Id_4" = "6c59ec8c-5afe-433e-a9b4-ebc1d652756e";
      "kwinrc"."Desktops"."Id_5" = "360df79a-e996-42a5-89c8-4c08e79ceee8";
      "kwinrc"."Desktops"."Id_6" = "9bd92a79-d6c9-491e-8e74-435dd9863fd1";
      "kwinrc"."Desktops"."Id_7" = "35792953-07cc-4acf-9f03-256e6062a421";
      "kwinrc"."Desktops"."Id_8" = "a064cb33-0300-4fb2-8f1f-0c6b0e94ea36";
      "kwinrc"."Desktops"."Number" = 8;
      "kwinrc"."Desktops"."Rows" = 2;
      "kwinrc"."Plugins"."desktopchangeosdEnabled" = true;
      "kwinrc"."Script-desktopchangeosd"."PopupHideDelay" = 250;

      # Frame color for active and inactive windows
      "kdeglobals"."WM"."frame" = "255,17,0";
      "kdeglobals"."WM"."inactiveFrame" = "153,153,153";
      "khotkeysrc"."WM"."frame[$d]" = "";
      "khotkeysrc"."WM"."inactiveFrame[$d]" = "";

      # Tiling gaps, 5px everywhere
      "kwinrc"."Script-bismuth"."screenGapBottom" = 5;
      "kwinrc"."Script-bismuth"."screenGapLeft" = 5;
      "kwinrc"."Script-bismuth"."screenGapRight" = 5;
      "kwinrc"."Script-bismuth"."screenGapTop" = 5;
      "kwinrc"."Script-bismuth"."tileLayoutGap" = 5;

      # Focus follows mouse
      "kwinrc"."Windows"."FocusPolicy" = "FocusFollowsMouse";
      "kwinrc"."Windows"."FocusStealingPreventionLevel" = 0;

      # WezTerm
      "kglobalshortcutsrc"."org.wezfurlong.wezterm.desktop"."_k_friendly_name" = "WezTerm";

      "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
      "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;
      "dolphinrc"."Open-with settings"."CompletionMode" = 1;
      "dolphinrc"."Open-with settings"."History" = "mpv";
      "kcminputrc"."Libinput.1267.12693.ELAN0678:00 04F3:3195 Touchpad"."ClickMethod" = 2;
      "kcminputrc"."Libinput.1267.12693.ELAN0678:00 04F3:3195 Touchpad"."NaturalScroll" = true;
      "kcminputrc"."Libinput.1267.12693.ELAN0678:00 04F3:3195 Touchpad"."TapDragLock" = true;
      "kcminputrc"."Libinput.1267.12693.ELAN0678:00 04F3:3195 Touchpad"."TapToClick" = true;
      "kcminputrc"."Mouse"."X11LibInputXAccelProfileFlat" = false;
      "kcminputrc"."Mouse"."cursorTheme" = "breeze_cursors";
      "kcminputrc"."Tmp"."update_info" = "delete_cursor_old_default_size.upd:DeleteCursorOldDefaultSize";
      "kded5rc"."Module-browserintegrationreminder"."autoload" = false;
      "kded5rc"."Module-device_automounter"."autoload" = false;
      "kded5rc"."PlasmaBrowserIntegration"."shownCount" = 4;
      "kdeglobals"."KDE"."AnimationDurationFactor" = 0;
      "kdeglobals"."General"."BrowserApplication" = "brave-browser.desktop";
      "kdeglobals"."General"."XftHintStyle" = "hintslight";
      "kdeglobals"."General"."XftSubPixel" = "none";
      "kdeglobals"."General"."fixed" = "Hack Nerd Font Mono,10,-1,5,50,0,0,0,0,0";
      "kdeglobals"."KDE"."SingleClick" = false;
      "kdeglobals"."KFileDialog Settings"."Allow Expansion" = false;
      "kdeglobals"."KFileDialog Settings"."Automatically select filename extension" = true;
      "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation" = true;
      "kdeglobals"."KFileDialog Settings"."Decoration position" = 2;
      "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode" = 5;
      "kdeglobals"."KFileDialog Settings"."Show Bookmarks" = false;
      "kdeglobals"."KFileDialog Settings"."Show Full Path" = false;
      "kdeglobals"."KFileDialog Settings"."Show Inline Previews" = true;
      "kdeglobals"."KFileDialog Settings"."Show Preview" = false;
      "kdeglobals"."KFileDialog Settings"."Show Speedbar" = true;
      "kdeglobals"."KFileDialog Settings"."Show hidden files" = false;
      "kdeglobals"."KFileDialog Settings"."Sort by" = "Date";
      "kdeglobals"."KFileDialog Settings"."Sort directories first" = true;
      "kdeglobals"."KFileDialog Settings"."Sort hidden files last" = false;
      "kdeglobals"."KFileDialog Settings"."Sort reversed" = true;
      "kdeglobals"."KFileDialog Settings"."Speedbar Width" = 138;
      "kdeglobals"."KFileDialog Settings"."View Style" = "DetailTree";
      "kdeglobals"."WM"."activeBackground" = "49,54,59";
      "kdeglobals"."WM"."activeBlend" = "252,252,252";
      "kdeglobals"."WM"."activeForeground" = "252,252,252";
      "kdeglobals"."WM"."inactiveBackground" = "42,46,50";
      "kdeglobals"."WM"."inactiveBlend" = "161,169,177";
      "kdeglobals"."WM"."inactiveForeground" = "161,169,177";
      "klaunchrc"."BusyCursorSettings"."Timeout" = 3;
      "klaunchrc"."TaskbarButtonSettings"."Timeout" = 3;
      "krunnerrc"."General"."FreeFloating" = true;
      "kscreenlockerrc"."Daemon"."LockGrace" = 10;
      "ksmserverrc"."General"."loginMode" = "emptySession";
      "kwalletrc"."Wallet"."First Use" = false;
      "kwinrc"."Compositing"."OpenGLIsUnsafe" = false;
      "kwinrc"."Effect-windowview"."BorderActivateAll" = 9;
      "kwinrc"."NightColor"."Active" = true;
      "kwinrc"."NightColor"."LatitudeAuto" = 59.327400;
      "kwinrc"."NightColor"."LatitudeFixed" = 59.11;
      "kwinrc"."NightColor"."LongitudeAuto" = 18.065300;
      "kwinrc"."NightColor"."LongitudeFixed" = 18.16;
      "kwinrc"."NightColor"."Mode" = "Location";
      "kwinrc"."NightColor"."NightTemperature" = 2500;
      "kwinrc"."Plugins"."kwin4_effect_maximizeEnabled" = false;
      "kwinrc"."TabBoxAlternative"."ActivitiesMode" = 0;
      "kwinrc"."TabBoxAlternative"."DesktopMode" = 0;
      "kwinrc"."Xwayland"."Scale" = 1;
      "kxkbrc"."Layout"."DisplayNames" = ",";
      "kxkbrc"."Layout"."LayoutList" = "us,se";
      "kxkbrc"."Layout"."Options" = "caps:escape,grp:alt_shift_toggle";
      "kxkbrc"."Layout"."ResetOldOptions" = true;
      "kxkbrc"."Layout"."Use" = true;
      "kxkbrc"."Layout"."VariantList" = ",";
      "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
      "plasmarc"."Theme"."name" = "breeze-dark";
      "plasmarc"."Wallpapers"."usersWallpapers" = "";
      "systemsettingsrc"."systemsettings_sidebar_mode"."HighlightNonDefaultSettings" = true;
    };
  };
}
