{ config, pkgs, inputs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    profiles = {
      lillecarl = {
        id = 0;
        isDefault = true;

        search = {
          default = "Kagi";
          force = true;

          engines = {
            "Kagi" = {
              urls = [{
                template = "https://kagi.com/search";
                params = [
                  { name = "q"; value = "{searchTerms}"; }
                ];
              }];
              icon = builtins.fetchurl {
                url = "https://assets.kagi.com/v1/favicon-32x32.png";
                sha256 = "sha256:1gmpn60hzzrmq1r5isfwvycnv793md578yz57fjr16zkilaw6svs";
              };
              definedAliases = [ "@kagi" ];
            };

            "Amazon.se".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "DuckDuckGo".metaData.hidden = true;
            "Google".metaData.hidden = true;
            "Wikipedia (en)".metaData.hidden = true;
          };
        };

        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          canvasblocker
          decentraleyes
          multi-account-containers
          onetab
          pkgs.firefoxAddons.kagi-search-for-firefox
          privacy-badger
          sponsorblock
          temporary-containers
          tree-style-tab
          tridactyl
          ublock-origin
        ];

        settings = {
          "browser.aboutConfig.showWarning" = false; # Boolean | To show warning prompt when accessing about:config page.
          "browser.newtabpage.activity-stream.feeds.telemetry" = false; # Disable telemetry
          "browser.newtabpage.activity-stream.telemetry" = false; # Disable telemetry
          "browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint" = ""; # Set telemetry server to empty string
          "browser.ping-centre.telemetry" = false; # Some kind of telemetry
          "browser.startup.homepage" = "https://ddg.co"; # String | Setting homepage for Firefox.
          "datareporting.healthreport.service.enabled" = false; # Boolean | Setting Firefox Health Report functionality (https://wiki.mozilla.org/Firefox_Health_Report)
          "datareporting.healthreport.uploadEnabled" = false; # Boolean | Setting Firefox Health Report uploading functionality.
          "datareporting.policy.dataSubmissionEnabled" = false; # Boolean | This is the data submission master kill switch. (https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html)
          "general.autoScroll" = true; # Press scroll wheel scroll
          "privacy.annotate_channels.strict_list.enabled" = true; # Boolean | Strict browsing
          "privacy.annotate_channels.strict_list.pbmode.enabled" = true; # Boolean | Strict browsing
          "privacy.donottrackheader.enabled" = true; # Boolean | DEPRECATED | Setting whether to send DNT header or not. (https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/DNT)
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Boolean | To reverse changes you made to Firefox with a userChrome.css or userContent.css file by setting to false.
          "toolkit.telemetry.archive.enabled" = false; # Disable telemetry
          "toolkit.telemetry.bhrPing.enabled" = false; # Disable telemetry
          "toolkit.telemetry.enabled" = false; # Disable telemetry
          "toolkit.telemetry.firstShutdownPing.enabled" = false; # Disable telemetry
          "toolkit.telemetry.prompted" = 2; # We've been asked about telemetry
          "toolkit.telemetry.rejected" = true; # We rejected telemetry
          "toolkit.telemetry.server" = ""; # Unconfigure telemetry server
          "toolkit.telemetry.unified" = false; # Not sure
          "toolkit.telemetry.unifiedIsOptIn" = false; # Don't opt in
          "toolkit.telemetry.updatePing.enabled" = false; # Don't ping things
        };

        userChrome = ''
          /* Hide tab bar */
          #tabbrowser-tabs { 
            visibility: collapse !important;
          }
          /* Hide side-bad header */
          #sidebar-header {
            visibility: collapse !important;
          }
          /* hide titlebar entirely */
          #titlebar {
            /* display: none !important; */
            visibility: collapse !important;
          }
        '';
        bookmarks = [
          {
            toolbar = true;
            bookmarks = [
              {
                name = "Home Manager";
                url = "https://nixos.wiki/wiki/Home_Manager";
              }
              {
                name = "Noogle Nix Search";
                url = "https://noogle.dev/";
              }
            ];
          }
          {
            toolbar = true;
            bookmarks = [
              {
                name = "Folder";
                bookmarks = [
                  {
                    name = "Home Manager";
                    url = "https://nixos.wiki/wiki/Home_Manager";
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
