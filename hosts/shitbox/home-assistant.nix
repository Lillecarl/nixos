{ config
, pkgs
, lib
, ...
}:
let
  domain = "hass.lillecarl.com";
  certdir = config.security.acme.certs.home-assistant.directory;
in
{
  systemd.services.home-assistant = {
    # Device scanning with NMAP
    path = [
      pkgs.nmap
    ];
    # Listen to DHCP requests
    serviceConfig.RestrictAddressFamilies = [
      "AF_PACKET"
    ];
  };
  services.home-assistant = {
    enable = true;
    openFirewall = true;

    extraPackages = (ps: with ps; [
      gtts
      aiohue
      radios
      androidtvremote2
      getmac
      spotipy
      pychromecast
      pycfdns
      python-nmap
      colorlog
      librouteros
      aiowebostv
    ]);

    config = {
      default_config = { };
      homeassistant = {
        name = "Home";
        #latitude = "!secret latitude";
        #longitude = "!secret longitude";
        #elevation = "!secret elevation";
        unit_system = "metric";
        time_zone = config.time.timeZone;
        external_url = "https://${domain}";
        country = "SE";
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      http = {
        server_host = "0.0.0.0";
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      device_tracker = lib.mkIf false [{
        platform = "mikrotik";
        host = " 192.168.88.1";
        username = "admin";
        password = ";m3gafuckyou";
        new_device_defaults = {
          track_new_devices = true;
        };
      }];
      script = {
        home_button = {
          sequence = [{
            service = "webostv.button";
            target = {
              entity_id = "media_player.lg_webos_smart_tv";
            };
            data = {
              button = "HOME";
            };
          }];
        };

        set_volume = {
          sequence = [{
            service = "webostv.command";
            target = {
              entity_id = "media_player.lg_webos_smart_tv";
            };
            data = {
              command = "audio/setVolume";
              payload.volume = "15";
            };
          }];
        };
        start_atv = {
          sequence = [
            {
              type = "turn_on";
              device_id = "b944cbc9241d3bf8b9d419e8cf3887f2";
              entity_id = "219103835fe4b015849f4ac220b05ea2";
              domain = "remote";
            }
            {
              service = "media_player.volume_set";
              metadata = { };
              data = {
                volume_level = 0.25;
              };
              target = {
                entity_id = "media_player.spotify_linearn111";
              };
            }
            {
              service = "media_player.select_source";
              data = {
                source = "Living Room TV";
              };
              target = {
                entity_id = "media_player.spotify_linearn111";
              };
            }
            {
              service = "media_player.play_media";
              data = {
                media_content_id = "https://open.spotify.com/playlist/37i9dQZF1DX6J5NfMJS675";
                media_content_type = "playlist";
              };
              target = {
                entity_id = "media_player.spotify_linearn111";
              };
            }
          ];
        };
      };
    };
  };

  security.acme.certs.home-assistant = {
    inherit domain;
    inherit (config.services.nginx) group;
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts.${domain} = {
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
    forceSSL = true;
    sslCertificate = "${certdir}/fullchain.pem";
    sslCertificateKey = "${certdir}/key.pem";
  };
}
