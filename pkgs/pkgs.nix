final: prev: flake:
let
  # python3 packages
  python3Packages = {
    ifupdown2 = prev.python3Packages.callPackage ../pkgs/python3Packages/ifupdown2 { };

    pyping = prev.python3Packages.callPackage ../pkgs/python3Packages/pyping { };
    hyprpy = prev.python3Packages.callPackage ../pkgs/python3Packages/hyprpy { };
    qutebrowser = qutebrowser false;
  };
  nodePackages = prev.callPackages ./node-packages { };

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
  terraform_1_5_5 = prev.mkTerraform {
    version = "1.5.5";
    hash = "sha256-SBS3a/CIUdyIUJvc+rANIs+oXCQgfZut8b0517QKq64=";
    vendorHash = "sha256-lQgWNMBf+ioNxzAV7tnTQSIS840XdI9fg9duuwoK+U4=";
    patches = [ "${prev.path}/pkgs/applications/networking/cluster/terraform/provider-path-0_15.patch" ];
  };

  qutebrowser = buildApplication: (prev.callPackage ./qutebrowser.nix {
    inherit (prev.__splicedPackages.qt6Packages) qtbase qtwebengine wrapQtAppsHook qtwayland;
    inherit buildApplication;
  }).overridePythonAttrs (oldAttrs: {
    patches = [ "${prev.path}/pkgs/applications/networking/browsers/qutebrowser/fix-restart.patch" ];
  });
in
prev.lib.filterAttrs
  (n: v:
    !flake
    ||
    # Flake is implicitly true here
    # Filter out package sets if we're called from a flake.
    (n != "python3Packages" && n != "nodePackages" && n != "grafanaPlugins" && n != "wrapFirefox"))
  {
    inherit miconoff mictoggle;
    inherit (python3Packages) ifupdown2;

    qutebrowser = qutebrowser true;

    # Inject python3 packages
    python3Packages = python3Packages // prev.python3Packages;
    python3 = prev.python3.override {
      packageOverrides = final: prev: { } // python3Packages;
    };
    # Inject node packages
    nodePackages = nodePackages // prev.nodePackages;
    # Inject grafanaPlugins
    grafanaPlugins = grafanaPlugins // prev.grafanaPlugins;

    inherit terraform_1_5_5;
    terraform = terraform_1_5_5;
    typos-lsp = prev.callPackage ./typos-lsp.nix { };
    hl = prev.callPackage ./hl.nix { };
    one-small-step-for-vimkind = prev.callPackage ./one-small-step-for-vimkind.nix { };
    copilotchat-nvim = prev.callPackage ./copilotchat-nvim.nix { };
    wrapFirefox = prev.callPackage ./wrapFirefox.nix { };
    nix-output-monitor =
      if (builtins.compareVersions
        "2.1.2"
        prev.nix-output-monitor.drvAttrs.version >= 0)
      then
        prev.nix-output-monitor.overrideAttrs
          (pattrs: {
            src = prev.fetchFromGitHub {
              owner = "maralorn";
              repo = "nix-output-monitor";
              rev = "5cc29ee7cc056bff2aac639e89d3389b77d52f7a";
              sha256 = "sha256-IDife7x1BKyxcQlCocVICUXXO+YIJzqj1Lgss8oWCUU=";
            };
          })
      else prev.nix-output-monitor;

    xwayland-satellite = prev.callPackage ./xwayland-satellite.nix { };

    usbutils2 = prev.usbutils.overrideAttrs (oldAttrs: {
      postInstall = ''
        moveToOutput "bin/lsusb.py" "$python"
        cp usbreset $out/bin/
      '';
    });
  }
// (
  if flake
  then python3Packages
  else { }
)
// (
  if flake
  then nodePackages
  else { }
)
  // (
  if flake
  then grafanaPlugins
  else { }
)
