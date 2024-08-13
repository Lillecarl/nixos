final: prev: flake:
let
  # python3 packages
  python3Packages = {
    pyping = prev.python3Packages.callPackage ../pkgs/python3Packages/pyping { };
    hyprpy = prev.python3Packages.callPackage ../pkgs/python3Packages/hyprpy { };
    qemu-qmp = prev.python3Packages.callPackage ../pkgs/python3Packages/qemu-qmp { };
  };

  grafanaPlugins = {
    frser-sqlite-datasource = prev.grafanaPlugins.callPackage ./grafanaPlugins/frser-sqlite-datasource { };
  };
  mictoggle = prev.writeShellScript "mictoggle" ''
    # Get mute status
    source_mute=$(${prev.pulseaudio}/bin/pactl get-source-mute @DEFAULT_SOURCE@)

    muted=1
    mute=0
    if [[ "$source_mute" == *"no"* ]]; then
      muted=0
      mute=1
    fi
    ${miconoff} $mute
  '';

  miconoff = prev.writeShellScript "miconoff" ''
    export mute=$1
    ${prev.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ $mute
    echo $mute > /sys/class/leds/platform\:\:micmute/brightness
  '';
in
prev.lib.filterAttrs
  (n: v:
    !flake
    ||
    # Flake is implicitly true here
    # Filter out package sets if we're called from a flake.
    (n != "python3Packages" && n != "grafanaPlugins"))
  {
    inherit miconoff mictoggle;

    # Inject python3 packages
    python3Packages = python3Packages // prev.python3Packages;
    python3 = prev.python3.override {
      packageOverrides = final: prev: { } // python3Packages;
    };
    # Inject grafanaPlugins
    grafanaPlugins = grafanaPlugins // prev.grafanaPlugins;

    typos-lsp = prev.callPackage ./typos-lsp.nix { };
    hl = prev.callPackage ./hl.nix { };
    one-small-step-for-vimkind = prev.callPackage ./one-small-step-for-vimkind.nix { };
    copilotchat-nvim = prev.callPackage ./copilotchat-nvim.nix { };
    xwayland-satellite = prev.callPackage ./xwayland-satellite.nix { };

    usbutils2 = prev.usbutils.overrideAttrs (oldAttrs: {
      postInstall = ''
        moveToOutput "bin/lsusb.py" "$python"
        cp usbreset $out/bin/
      '';
    });
    vieb = prev.vieb.overrideAttrs (pattrs: {
      postInstall = ''
        install -Dm0644 {${pattrs.desktopItem},$out}/share/applications/vieb.desktop

        pushd $out/lib/node_modules/vieb/app/img/icons
        for file in *.png; do
          install -Dm0644 $file $out/share/icons/hicolor/''${file//.png}/apps/vieb.png
        done
        popd

        makeWrapper ${prev.electron}/bin/electron $out/bin/vieb \
          --add-flags $out/lib/node_modules/vieb/app \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
          --set npm_package_version ${pattrs.version}
      '';
    });

    catppuccin-cursors2 = import ./catppuccin-cursors.nix {
      inherit (prev)
        lib
        stdenvNoCC
        fetchFromGitHub
        inkscape
        just;
      inherit (prev.xorg) xcursorgen;
    };

    pllua = prev.callPackage ./pllua.nix {
      lua = prev.lua5_4.override {
        version = "5.4.7";
        hash = "sha256-n79eKO+GxphY9tPTTszDLpEcGii0Eg/z6EqqcM+/HjA=";
      };
    };
    pllua_jit = prev.callPackage ./pllua.nix {
      lua = (prev.luajit_2_1.override { enable52Compat = true; }).overrideAttrs (oldAttrs: {
        # workaround for stupid pllua Makefile
        postFixup = ''
          ln -s $out/bin/luajit $out/bin/luac
        '';
      });
    };

    plprql = prev.callPackage ./plprql.nix { };
    pg_graphql = prev.callPackage ./pg_graphql.nix { };
    pg_jsonschema = prev.callPackage ./pg_jsonschema.nix { };
    pg_analytics = prev.callPackage ./pg_analytics.nix { };
  }
//
(
  if flake
  then python3Packages
  else { }
) //
(
  if flake
  then grafanaPlugins
  else { }
)
