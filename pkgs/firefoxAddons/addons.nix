{ buildFirefoxXpiAddon, fetchurl, lib, stdenv }:
{
  "bitwarden-password-manager" = buildFirefoxXpiAddon {
    pname = "bitwarden-password-manager";
    version = "2023.4.0";
    addonId = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4103016/bitwarden_password_manager-2023.4.0.xpi";
    sha256 = "484eb6a64d36ed5ee3c7e5d62d09367cc3a6477ff80dabd13e1dc1e92ca87b28";
    meta = with lib;
      {
        homepage = "https://bitwarden.com";
        description = "A secure and free password manager for all of your devices.";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
  };
  "canvasblocker" = buildFirefoxXpiAddon {
    pname = "canvasblocker";
    version = "1.9";
    addonId = "CanvasBlocker@kkapsner.de";
    url = "https://addons.mozilla.org/firefox/downloads/file/4097901/canvasblocker-1.9.xpi";
    sha256 = "5248c2c2dedd14b8aa2cd73f9484285d9453e93339f64fcf04a3d63c859cf3d7";
    meta = with lib;
      {
        homepage = "https://github.com/kkapsner/CanvasBlocker/";
        description = "Alters some JS APIs to prevent fingerprinting.";
        license = licenses.mpl20;
        platforms = platforms.all;
      };
  };
  "decentraleyes" = buildFirefoxXpiAddon {
    pname = "decentraleyes";
    version = "2.0.17";
    addonId = "jid1-BoFifL9Vbdl2zQ@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/3902154/decentraleyes-2.0.17.xpi";
    sha256 = "e7f16ddc458eb2bc5bea75832305895553fca53c2565b6f1d07d5d9620edaff1";
    meta = with lib;
      {
        homepage = "https://decentraleyes.org";
        description = "Protects you against tracking through \"free\", centralized, content delivery. It prevents a lot of requests from reaching networks like Google Hosted Libraries, and serves local files to keep sites from breaking. Complements regular content blockers.";
        license = licenses.mpl20;
        platforms = platforms.all;
      };
  };
  "kagi-search-for-firefox" = buildFirefoxXpiAddon {
    pname = "kagi-search-for-firefox";
    version = "0.2";
    addonId = "search@kagi.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3942576/kagi_search_for_firefox-0.2.xpi";
    sha256 = "3fd046ba0332fa76bc00bedf0f9d1c9282618c1545016bbfde246b1c8f34d311";
    meta = with lib;
      {
        description = "A simple helper extension for setting Kagi as a default search engine, and automatically logging in to Kagi in private browsing windows.";
        license = licenses.mpl20;
        platforms = platforms.all;
      };
  };
  "multi-account-containers" = buildFirefoxXpiAddon {
    pname = "multi-account-containers";
    version = "8.1.2";
    addonId = "@testpilot-containers";
    url = "https://addons.mozilla.org/firefox/downloads/file/4058426/multi_account_containers-8.1.2.xpi";
    sha256 = "0ab8f0222853fb68bc05fcf96401110910dfeb507aaea2cf88c5cd7084d167fc";
    meta = with lib;
      {
        homepage = "https://github.com/mozilla/multi-account-containers/#readme";
        description = "Firefox Multi-Account Containers lets you keep parts of your online life separated into color-coded tabs. Cookies are separated by container, allowing you to use the web with multiple accounts and integrate Mozilla VPN for an extra layer of privacy.";
        license = licenses.mpl20;
        platforms = platforms.all;
      };
  };
  "onetab" = buildFirefoxXpiAddon {
    pname = "onetab";
    version = "1.59";
    addonId = "extension@one-tab.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3946687/onetab-1.59.xpi";
    sha256 = "8976b6841f3f729d349a23333e6544c4e973ada7486a8a20f85e151d65ca6191";
    meta = with lib;
      {
        homepage = "http://www.one-tab.com";
        description = "OneTab - Too many tabs? Convert tabs to a list and reduce browser memory";
        platforms = platforms.all;
      };
  };
  "privacy-badger17" = buildFirefoxXpiAddon {
    pname = "privacy-badger17";
    version = "2023.1.31";
    addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/file/4064595/privacy_badger17-2023.1.31.xpi";
    sha256 = "0082d8ffe7b25f370a313d9b899b0c1ba1669b21b3a11791fe5ecf031aeb6a6c";
    meta = with lib;
      {
        homepage = "https://privacybadger.org/";
        description = "Automatically learns to block invisible trackers.";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
  };
  "shortkeys" = buildFirefoxXpiAddon {
    pname = "shortkeys";
    version = "4.0.2";
    addonId = "Shortkeys@Shortkeys.com";
    url = "https://addons.mozilla.org/firefox/downloads/file/3673761/shortkeys-4.0.2.xpi";
    sha256 = "c6fe12efdd7a871787ac4526eea79ecc1acda8a99724aa2a2a55c88a9acf467c";
    meta = with lib;
      {
        homepage = "https://github.com/mikecrittenden/shortkeys";
        description = "Easily customizable custom keyboard shortcuts for Firefox. To configure this addon go to Addons (ctrl+shift+a) -&gt;Shortkeys -&gt;Options. Report issues here (please specify that the issue is found in Firefox): <a rel=\"nofollow\" href=\"https://prod.outgoing.prod.webservices.mozgcp.net/v1/12e2f788f1bdde9c64f3afef23153608411c53de3620e6fd118a93baa51449f4/https%3A//github.com/mikecrittenden/shortkeys\">https://github.com/mikecrittenden/shortkeys</a>";
        license = licenses.mit;
        platforms = platforms.all;
      };
  };
  "sponsorblock" = buildFirefoxXpiAddon {
    pname = "sponsorblock";
    version = "5.4.1";
    addonId = "sponsorBlocker@ajay.app";
    url = "https://addons.mozilla.org/firefox/downloads/file/4098861/sponsorblock-5.4.1.xpi";
    sha256 = "a7ceb7b83271f62d8619bc46e797592dc662b133cbff29e928a77c9fff9219f3";
    meta = with lib;
      {
        homepage = "https://sponsor.ajay.app";
        description = "Easily skip YouTube video sponsors. When you visit a YouTube video, the extension will check the database for reported sponsors and automatically skip known sponsors. You can also report sponsors in videos.\n\nOther browsers: https://sponsor.ajay.app";
        license = licenses.lgpl3;
        platforms = platforms.all;
      };
  };
  "temporary-containers" = buildFirefoxXpiAddon {
    pname = "temporary-containers";
    version = "1.9.2";
    addonId = "{c607c8df-14a7-4f28-894f-29e8722976af}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3723251/temporary_containers-1.9.2.xpi";
    sha256 = "3340a08c29be7c83bd0fea3fc27fde71e4608a4532d932114b439aa690e7edc0";
    meta = with lib;
      {
        homepage = "https://github.com/stoically/temporary-containers";
        description = "Open tabs, websites, and links in automatically managed disposable containers which isolate the data websites store (cookies, storage, and more) from each other, enhancing your privacy and security while you browse.";
        license = licenses.mit;
        platforms = platforms.all;
      };
  };
  "tree-style-tab" = buildFirefoxXpiAddon {
    pname = "tree-style-tab";
    version = "3.9.15";
    addonId = "treestyletab@piro.sakura.ne.jp";
    url = "https://addons.mozilla.org/firefox/downloads/file/4088468/tree_style_tab-3.9.15.xpi";
    sha256 = "7c993bae2d43488615f1a3b7459a2c35730a486b3855049709c636a84751d252";
    meta = with lib;
      {
        homepage = "http://piro.sakura.ne.jp/xul/_treestyletab.html.en";
        description = "Show tabs like a tree.";
        platforms = platforms.all;
      };
  };
  "ublock-origin" = buildFirefoxXpiAddon {
    pname = "ublock-origin";
    version = "1.49.2";
    addonId = "uBlock0@raymondhill.net";
    url = "https://addons.mozilla.org/firefox/downloads/file/4103048/ublock_origin-1.49.2.xpi";
    sha256 = "39266486f720cd31d291d2fdad78625b079782a05517e1936eec7e780bc2a84d";
    meta = with lib;
      {
        homepage = "https://github.com/gorhill/uBlock#ublock-origin";
        description = "Finally, an efficient wide-spectrum content blocker. Easy on CPU and memory.";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
  };
  "zen-fox" = buildFirefoxXpiAddon {
    pname = "zen-fox";
    version = "1.9.9";
    addonId = "{4b7db180-f46c-4955-afaf-a03913751acc}";
    url = "https://addons.mozilla.org/firefox/downloads/file/3692640/zen_fox-1.9.9.xpi";
    sha256 = "bac5c909de8f17473ba6823999927e809ee8e9c2165a94f40c1f521a1396cb5e";
    meta = with lib;
      {
        homepage = "https://github.com/mr-islam/zen-fox";
        description = "Theme Firefox to suit you, day or night, solarized.\n\nFirefox has never looked this good.";
        license = licenses.gpl2;
        platforms = platforms.all;
      };
  };
}
