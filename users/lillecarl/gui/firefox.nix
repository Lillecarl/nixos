{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.ps.gui.enable {
    # Looks weird, but firefox requires kitty and neovim on PATH for tridactyl
    # native-messenger editing
    home.packages = [
      config.programs.kitty.package
      config.programs.neovim.package
    ];

    stylix.targets.firefox.profileNames = [ "lillecarl" ];

    programs.firefox = {
      enable = true;

      nativeMessagingHosts = [
        pkgs.ff2mpv
        pkgs.tridactyl-native
      ];

      profiles = {
        lillecarl = {
          id = 0;
          isDefault = true;

          # TODO: Fix something for containers that doesn't suck

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

          extensions =
            with pkgs.nur.repos.rycee.firefox-addons;
            (
              [
                # Normal extensions
                bitwarden
                canvasblocker
                consent-o-matic
                cookie-autodelete
                decentraleyes
                multi-account-containers
                onetab
                kagi-search
                privacy-badger
                privacy-pass
                sponsorblock
                temporary-containers
                tree-style-tab
                ublock-origin
              ]
              ++ [
                # Native messaging hosts
                ff2mpv
                tridactyl
              ]
            );

          settings = {
            # A lot of settings are taken from here: https://github.com/yokoffing/Betterfox/blob/main/user.js

            # Fastfox
            "browser.startup.preXulSkeletonUI" = false;
            "content.notify.interval" = 100000;
            "nglayout.initialpaint.delay" = 0;
            "nglayout.initialpaint.delay_in_oopif" = 0;
            # Speculative connections
            "browser.places.speculativeConnect.enabled" = false;
            "browser.urlbar.speculativeConnect.enabled" = false;
            "network.dns.disablePrefetch" = true;
            "network.http.speculative-parallel-limit" = 0;
            "network.predictor.enable-prefetch" = false;
            "network.predictor.enabled" = false;
            "network.prefetch-next" = false;
            # Passwords and autofill
            "editor.truncate_user_pastes" = false;
            "signon.autofillForms" = false;
            "signon.formlessCapture.enabled" = false;
            "signon.privateBrowsingCapture.enabled" = false;
            "signon.rememberSignons" = false;
            # Address + CC manager
            "browser.formfill.enable" = false;
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            "extensions.formautofill.heuristics.enabled" = false;
            # Telemetry
            "app.normandy.api_url" = "";
            "app.normandy.enabled" = false;
            "app.shield.optoutstudies.enabled" = false;
            "breakpad.reportURL" = "";
            "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
            "browser.discovery.enabled" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "browser.tabs.crashReporting.sendReport" = false;
            "captivedetect.canonicalURL" = "";
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "default-browser-agent.enabled" = false;
            "network.captive-portal-service.enabled" = false;
            "network.connectivity-service.enabled" = false;
            "toolkit.coverage.opt-out" = true;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.coverage.opt-out" = true;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.server" = "data:,";
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            # Misc
            "accessibility.force_disabled" = 1; # disable accessibility, improves performance
            "app.update.auto" = false; # don't auto update
            "browser.aboutConfig.showWarning" = false; # to show warning prompt when accessing about:config page.
            "browser.ctrlTab.sortByRecentlyUsed" = true; # ctrl + tab sort tabs by recently used
            "browser.newtabpage.activity-stream.telemetry.structuredIngestion.endpoint" = ""; # Set telemetry server to empty string
            "browser.shell.checkDefaultBrowser" = false; # don't ask about default browser
            "browser.startup.homepage" = "about:blank"; # set startup page to empty page
            "browser.startup.page" = 3; # restore sessions on startup
            "dom.successive_dialog_time_limit" = 1; # don't allow websites to abuse prompts.
            "extensions.pocket.enabled" = false; # Disable pocket
            "extensions.update.autoUpdateDefault" = false; # don't auto update extensions
            "general.autoScroll" = true; # press scroll wheel scroll
            "privacy.annotate_channels.strict_list.enabled" = true; # strict browsing
            "privacy.annotate_channels.strict_list.pbmode.enabled" = true; # strict browsing
            "privacy.donottrackheader.enabled" = true; # setting whether to send DNT header or not. (https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/DNT)
            "privacy.resistFingerprinting" = false; # can't use this because it fucks with timezone
            "privacy.trackingprotection.enabled" = true; # tracking protection
            "privacy.trackingprotection.socialtracking.enabled" = true; # social tracking protection
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # enable userChrome
            "toolkit.telemetry.pioneer-new-studies-available" = false; # don't ping things
            "toolkit.telemetry.prompted" = 2; # we've been asked about telemetry
            "toolkit.telemetry.rejected" = true; # we rejected telemetry
            "toolkit.telemetry.unifiedIsOptIn" = false; # don't opt in
            "ui.prefersReducedMotion" = true; # Reduce web animations

            # Meeting overlay thingie doesn't work well when tiling
            "privacy.webrtc.legacyGlobalIndicator" = false;
            "privacy.webrtc.hideGlobalIndicator" = true;
            "browser.privatebrowsing.enable-new-indicator" = true;
            # Font
            "font.name.monospace.x-western" = "Hack Nerd Font";

            # Smooth scrolling
            "general.smoothScroll.scrollbars.durationMaxMS" = 600;
            "general.smoothScroll.mouseWheel.durationMaxMS" = 275;
            "general.smoothScroll.other.durationMaxMS" = 150;
            "general.smoothScroll.pages.durationMaxMS" = 150;
            "general.smoothScroll.lines.durationMaxMS" = 150;
            "general.smoothScroll.pixels.durationMaxMS" = 150;
            "toolkit.scrollbox.horizontalScrollDistance" = 6;
            "toolkit.scrollbox.verticalScrollDistance" = 6;
            "layers.async-pan-zoom.enabled" = true;
            "mousewheel.min_line_scroll_amount" = 12;
            "mousewheel.acceleration.factor" = 10;
            "mousewheel.acceleration.start" = 0;
            "mousewheel.default.delta_multiplier_x" = 100;
            "mousewheel.default.delta_multiplier_y" = 100;
            "mousewheel.default.delta_multiplier_z" = 100;
            "mousewheel.system_scroll_override_on_root_content.enabled" = false;
            "mousewheel.transaction.timeout" = 2000;
            "general.smoothScroll.scrollbars.durationMinMS" = 0;
            "general.smoothScroll.mouseWheel.durationMinMS" = 0;
            "general.smoothScroll.other.durationMinMS" = 0;
            "general.smoothScroll.pages.durationMinMS" = 0;
            "general.smoothScroll.lines.durationMinMS" = 0;
            "general.smoothScroll.pixels.durationMinMS" = 0;
            "general.smoothScroll.currentVelocityWeighting" = 0;
            "general.smoothScroll.stopDecelerationWeighting" = 0.2;
            "general.smoothScroll.durationToIntervalRatio" = 2000;
            "general.smoothScroll.msdPhysics.enabled" = false;
            "general.smoothScroll.mouseWheel.migrationPercent" = 100;
          };

          userChrome = # css
            ''
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
  };
}
