final: prev: flake:
let
  # python3 packages
  python3Packages = {
    xonsh-direnv = prev.callPackage ../pkgs/python3Packages/xonsh-direnv { };
    xontrib-abbrevs = prev.callPackage ../pkgs/python3Packages/xontrib-abbrevs { };
    xontrib-back2dir = prev.callPackage ../pkgs/python3Packages/xontrib-back2dir { };
    xontrib-argcomplete = prev.callPackage ../pkgs/python3Packages/xontrib-argcomplete { };
    xontrib-autoxsh = prev.callPackage ../pkgs/python3Packages/xontrib-autoxsh { };
    xontrib-fzf-widgets = prev.callPackage ../pkgs/python3Packages/xontrib-fzf-widgets { };
    xontrib-jump-to-dir = prev.callPackage ../pkgs/python3Packages/xontrib-jump-to-dir { };
    xontrib-onepath = prev.callPackage ../pkgs/python3Packages/xontrib-onepath { };
    xontrib-output-search = prev.callPackage ../pkgs/python3Packages/xontrib-output-search { };
    xontrib-sh = prev.callPackage ../pkgs/python3Packages/xontrib-sh { };
    tokenize-output = prev.callPackage ../pkgs/python3Packages/tokenize-output { };
    lazyasd = prev.callPackage ../pkgs/python3Packages/lazyasd { };

    exabgp = prev.callPackage ../pkgs/python3Packages/exabgp { };

    from_ssv = prev.python3Packages.callPackage ../pkgs/python3Packages/from_ssv { };
    pyping = prev.python3Packages.callPackage ../pkgs/python3Packages/pyping { };
  };
  nodePackages = prev.callPackages ./node-packages { };

  grafanaPlugins = {
    frser-sqlite-datasource = prev.grafanaPlugins.callPackage ./grafanaPlugins/frser-sqlite-datasource { };
  };
in
prev.lib.filterAttrs
  (n: v:
    flake
    == false
    ||
    # Flake is implicitly true here
    # Filter out package sets if we're called from a flake.
    (n != "python3Packages" && n != "nodePackages" && n != "firefoxAddons" && n != "grafanaPlugins"))
  {
    keychain-wrapper = prev.callPackage ../pkgs/keychain-wrapper { };

    xonsh-joined = prev.callPackage ../pkgs/xonsh-joined { };
    xonsh-wrapper = final.callPackage ../pkgs/xonsh-wrapper { };

    # Inject python3 packages
    python3Packages = python3Packages // prev.python3Packages;
    python3 = prev.python3.override {
      packageOverrides = final: prev: { } // python3Packages;
    };
    # Inject node packages
    nodePackages = nodePackages // prev.nodePackages;
    # Inject grafanaPlugins
    grafanaPlugins = grafanaPlugins // prev.grafanaPlugins;
    # firefox addons
    firefoxAddons = prev.callPackage ./firefoxAddons { };

    obs-studio = prev.obs-studio.overrideAttrs (finalAttrs: previousAttrs: rec {
      version = "30.0.0-beta2";
      src = prev.fetchFromGitHub {
        owner = "obsproject";
        repo = "obs-studio";
        rev = version;
        sha256 = "sha256-OhsPKLNzA88PecIduB8GsxvyzRwIrdxYQbJVJIspfuQ=";
        fetchSubmodules = true;
      };

      patches = [
        (builtins.fetchurl {
          url = "https://raw.githubusercontent.com/NixOS/nixpkgs/2f9286912cb215969ece465147badf6d07aa43fe/pkgs/applications/video/obs-studio/fix-nix-plugin-path.patch";
          sha256 = "sha256:0dn1lrw77f3322bizagdpxh79ars53nj6yardw2fhdzgk50fcjna";
        })
      ];

      buildInputs = previousAttrs.buildInputs ++ [
        prev.libdatachannel
      ];

      cmakeFlags = previousAttrs.cmakeFlags ++ [
        "-DENABLE_QSV11=OFF"
      ];
    });

    mictoggle = prev.writeShellScript "mictoggler" ''
      # Get default source
      default_source=$(${prev.pulseaudio}/bin/pactl get-default-source)
      # Get mute status
      source_mute=$(${prev.pulseaudio}/bin/pactl get-source-mute "$default_source")

      mute=1
      if [[ "$source_mute" == *"yes"* ]]; then
        mute=0
      fi

      ${prev.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ $mute
      ${prev.coreutils-full}/bin/sleep 0.5
      echo $mute > /sys/class/leds/platform\:\:micmute/brightness
    '';
  }
// (
  if flake == true
  then python3Packages
  else { }
)
// (
  if flake == true
  then nodePackages
  else { }
)
  // (
  if flake == true
  then grafanaPlugins
  else { }
)
