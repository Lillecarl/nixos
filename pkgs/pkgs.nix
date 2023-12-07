final: prev: flake:
let
  # python3 packages
  python3Packages = {
    pyping = prev.python3Packages.callPackage ../pkgs/python3Packages/pyping { };
  };
  nodePackages = prev.callPackages ./node-packages { };

  grafanaPlugins = {
    frser-sqlite-datasource = prev.grafanaPlugins.callPackage ./grafanaPlugins/frser-sqlite-datasource { };
  };
  mictoggle = prev.writeShellScript "mictoggle" ''
    # Get default source
    default_source=$(${prev.pulseaudio}/bin/pactl get-default-source)
    # Get mute status
    source_mute=$(${prev.pulseaudio}/bin/pactl get-source-mute "$default_source")

    mute=1
    if [[ "$source_mute" == *"yes"* ]]; then
      mute=0
    fi
    ${miconoff} $mute
  '';

  miconoff = prev.writeShellScript "mictoggle" ''
    export mute=$1
    ${prev.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ $mute
    echo $mute > /sys/class/leds/platform\:\:micmute/brightness
  '';
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
    inherit miconoff mictoggle;

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

    terraform_1_5_5 = prev.mkTerraform {
      version = "1.5.5";
      hash = "sha256-SBS3a/CIUdyIUJvc+rANIs+oXCQgfZut8b0517QKq64=";
      vendorHash = "sha256-lQgWNMBf+ioNxzAV7tnTQSIS840XdI9fg9duuwoK+U4=";
      patches = [ "${prev.path}/pkgs/applications/networking/cluster/terraform/provider-path-0_15.patch" ];
    };


    keyd = prev.callPackage ./tmp/keyd.nix { };
    keymapper = prev.keymapper.overrideAttrs (pattrs: {
      src = prev.fetchFromGitHub {
        owner = "houmain";
        repo = "keymapper";
        rev = "3.2.0";
        sha256 = "sha256-yjB7tE/MamuG1waQ+A3sqiXmTSD4W0mtygzypwi2aQI=";
      };

      nativeBuildInputs = pattrs.nativeBuildInputs ++ [
        prev.libxkbcommon
      ];
    });
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
