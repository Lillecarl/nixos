final: prev: flake:
let
  # python3 packages
  python3Packages = {
    pyping = prev.python3Packages.callPackage ../pkgs/python3Packages/pyping { };
    qemu-qmp = prev.python3Packages.callPackage ../pkgs/python3Packages/qemu-qmp { };
    konnect = prev.python3Packages.callPackage ../pkgs/python3Packages/konnect { };
  };

  grafanaPlugins = {
    frser-sqlite-datasource =
      prev.grafanaPlugins.callPackage ./grafanaPlugins/frser-sqlite-datasource
        { };
  };
in
prev.lib.filterAttrs
  (
    n: v:
    !flake
    ||
      # Flake is implicitly true here
      # Filter out package sets if we're called from a flake.
      (n != "python3Packages" && n != "grafanaPlugins")
  )
  {
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
    pgmq = prev.callPackage ./pgmq.nix { };
    pg_graphql = prev.callPackage ./pg_graphql.nix { };
    pg_jsonschema = prev.callPackage ./pg_jsonschema.nix { };
    pg_analytics = prev.callPackage ./pg_analytics.nix { };
    writeJinja2 = prev.python3Packages.callPackage ./writeJinja2.nix { };
  }
// (if flake then python3Packages else { })
// (if flake then grafanaPlugins else { })
