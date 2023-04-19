{ fetchurl
, lib
, stdenv
,
} @ args:
let
  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? args.stdenv
                                              , fetchurl ? args.fetchurl
                                              , pname
                                              , version
                                              , addonId
                                              , url
                                              , sha256
                                              , meta
                                              , ...
                                              }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });

  packages = import ./addons.nix {
    inherit buildFirefoxXpiAddon fetchurl lib stdenv;
  };
in
packages
  // {
  inherit buildFirefoxXpiAddon;

  #"1password-x-password-manager" = packages.onepassword-password-manager;

  bypass-paywalls-clean =
    let
      version = "3.1.0.0";
    in
    buildFirefoxXpiAddon {
      pname = "bypass-paywalls-clean";
      inherit version;
      addonId = "{d133e097-46d9-4ecc-9903-fa6a722a6e0e}";
      url = "https://gitlab.com/magnolia1234/bpc-uploads/-/raw/master/bypass_paywalls_clean-${version}.xpi";
      sha256 = "sha256-UjKLcl3kcZo+fbqkkOmtrmcqtQ6Wy+SM6hf8ZiWT+Uw=";
      meta = with lib; {
        homepage = "https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean";
        description = "Bypass Paywalls of (custom) news sites";
        license = licenses.mit;
        platforms = platforms.all;
      };
    };

  gaoptout = buildFirefoxXpiAddon {
    pname = "gaoptout";
    version = "1.0.8";
    addonId = "{6d96bb5e-1175-4ebf-8ab5-5f56f1c79f65}";
    url = "https://dl.google.com/analytics/optout/gaoptoutaddon_1.0.8.xpi";
    sha256 = "vJKe77kKcEOrSkpDJ3nGW3j155heOgojFkDroySE0r8=";
    meta = with lib; {
      homepage = "https://tools.google.com/dlpage/gaoptout";
      description = "Tells the Google Analytics JavaScript not to send information to Google Analytics.";
      license = {
        shortName = "gaooba";
        fullName = "Google Analytics Opt-out Browser Add-on - Additional Terms of Service";
        url = "http://tools.google.com/dlpage/gaoptout/intl/en/eula_text.html";
        free = false;
      };
      platforms = platforms.all;
    };
  };

  proxydocile = buildFirefoxXpiAddon {
    pname = "proxydocile";
    version = "2.3";
    addonId = "proxydocile@unipd.it";
    url = "https://softwarecab.cab.unipd.it/proxydocile/proxydocile.xpi";
    sha256 = "sha256-Xz6BpDHtqbLfTbmlXiNMzUkqRxmEtPw3q+JzvpzA938=";
    meta = with lib; {
      homepage = "https://bibliotecadigitale.cab.unipd.it/bd/proxy/proxy-docile";
      description = "Automatically connect to university proxy.";
      platforms = platforms.all;
    };
  };

  trilium-web-clipper =
    let
      version = "0.3.1";
    in
    buildFirefoxXpiAddon {
      pname = "trilium-web-clipper";
      inherit version;
      addonId = "{1410742d-b377-40e7-a9db-63dc9c6ec99c}";
      url = "https://github.com/zadam/trilium-web-clipper/releases/download/v${version}/trilium_web_clipper-${version}-an+fx.xpi";
      sha256 = "sha256-P9ZBUWISJ3MqVpLUWSmiuHhrX4yPCVRnw8WQ7C4SaVs=";
      meta = with lib; {
        homepage = "https://github.com/zadam/trilium-web-clipper";
        description = "Save web clippings to Trilium Notes";
        license = licenses.gpl3Plus;
        platforms = platforms.all;
      };
    };
  name = "firefox-addon";
  type = "derivation";
}
