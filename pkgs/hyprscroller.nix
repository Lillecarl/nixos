{ lib
, hyprland
, hyprlandPlugins
, cmake
, src
}:
hyprlandPlugins.mkHyprlandPlugin hyprland {
  pluginName = "hyprscroller";
  inherit (hyprland) version;

  inherit src;

  installPhase = ''
    mkdir -p $out/lib/
    cp hyprscroller.so $out/lib/libhyprscroller.so
  '';

  nativeBuildInputs = [ cmake ];
  dontStrip = true;

  meta = with lib; {
    homepage = "https://github.com/dawsers/hyprscroller";
    description = "PaperWM / niri scrolling for Hyprland";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
