{ config
, pkgs
, inputs
, ...
}: {
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
              urls = [
                {
                  template = "https://kagi.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
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
          "browser.aboutConfig.showWarning" = false; # to show warning prompt when accessing about:config page.
          "browser.ctrlTab.sortByRecentlyUsed" = true; # ctrl + tab sort tabs by recently used
          "browser.newtabpage.activity-stream.feeds.telemetry" = false; # disable telemetry
          "browser.newtabpage.activity-stream.telemetry" = false; # disable telemetry
          "browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint" = ""; # Set telemetry server to empty string
          "browser.ping-centre.telemetry" = false; # some kind of telemetry
          "browser.shell.checkDefaultBrowser" = false; # don't ask about default browser
          "browser.startup.homepage" = "about:blank"; # set startup page to empty page
          "datareporting.healthreport.service.enabled" = false; # setting Firefox Health Report functionality (https://wiki.mozilla.org/Firefox_Health_Report)
          "datareporting.healthreport.uploadEnabled" = false; # setting Firefox Health Report uploading functionality.
          "datareporting.policy.dataSubmissionEnabled" = false; # this is the data submission master kill switch. (https://firefox-source-docs.mozilla.org/toolkit/components/telemetry/internals/preferences.html)
          "dom.successive_dialog_time_limit" = 1; # don't allow websites to abuse prompts.
          "general.autoScroll" = true; # press scroll wheel scroll
          "privacy.annotate_channels.strict_list.enabled" = true; # strict browsing
          "privacy.annotate_channels.strict_list.pbmode.enabled" = true; # strict browsing
          "privacy.donottrackheader.enabled" = true; # setting whether to send DNT header or not. (https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/DNT)
          "privacy.resistFingerprinting" = true; # resist fingerprinting
          "privacy.trackingprotection.enabled" = true; # tracking protection
          "privacy.trackingprotection.socialtracking.enabled" = true; # social tracking protection
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # enable userChrome
          "toolkit.telemetry.archive.enabled" = false; # disable telemetry
          "toolkit.telemetry.bhrPing.enabled" = false; # disable telemetry
          "toolkit.telemetry.enabled" = false; # disable telemetry
          "toolkit.telemetry.firstShutdownPing.enabled" = false; # disable telemetry
          "toolkit.telemetry.prompted" = 2; # we've been asked about telemetry
          "toolkit.telemetry.rejected" = true; # we rejected telemetry
          "toolkit.telemetry.server" = ""; # unconfigure telemetry server
          "toolkit.telemetry.unified" = false; # not sure
          "toolkit.telemetry.unifiedIsOptIn" = false; # don't opt in
          "toolkit.telemetry.updatePing.enabled" = false; # don't ping things
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
