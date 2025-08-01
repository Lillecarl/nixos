{ pkgs, ... }:
let
  PULSE_SERVER = "unix:///run/pulse/native";
in
{
  # Restream webcam to virtual camera
  # boot.kernelModules = [
  #   "v4l2loopback"
  # ];
  environment.variables = { inherit PULSE_SERVER; };
  systemd.globalEnvironment = { inherit PULSE_SERVER; };

  # rtkit to make pipewire schedule realtime
  security.rtkit.enable = true;

  # Enable PipeWire A/V daemon
  # replaces all other sound daemons
  services.pipewire = {
    enable = true;
    alsa.enable = true; # Required by: Audacity
    jack.enable = true; # Required by: Qtractor
    pulse.enable = true;
    wireplumber.enable = true;
    socketActivation = true;
    systemWide = true;
  };
  services.pipewire.extraConfig.pipewire.bufconf = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 256;
      "default.clock.min-quantum" = 128;
      "default.clock.max-quantum" = 2048;
    };
    "pulse.properties" = {
      "pulse.min.req" = "128/48000";
      "pulse.default.req" = "256/48000";
      "pulse.max.req" = "2048/48000";
      "pulse.min.quantum" = "128/48000";
      "pulse.max.quantum" = "2048/48000";
    };
  };
  services.pipewire.extraConfig.pipewire.rtconfig = {
    "context.modules" = [
      {
        name = "libpipewire-module-rt";
        args = {
          # Real-time priority (1-99, higher = more priority)
          "rt.prio" = 88;

          # Nice level for non-RT threads (-20 to 19, lower = higher priority)
          "nice.level" = -11;

          # RT time limits as fraction of period (alternative to above)
          "rt.time.soft" = -1; # Unlimited
          "rt.time.hard" = -1; # Unlimited

          # Use rtkit for acquiring RT privileges
          "uclamp.min" = 0;
          "uclamp.max" = 1024;
        };
        # flags = [
        #   "ifexists"
        #   "nofail"
        # ];
      }
    ];
  };
  services.pipewire.wireplumber.extraConfig = {
    disable-webcam-mic = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "device.name" = "alsa_input.usb-046d_HD_Pro_Webcam_C920_6B10B2DF-02.analog-stereo";
            }
          ];
          actions = {
            "update-props" = {
              "device.disabled" = true;
            };
          };
        }
        {
          matches = [
            {
              "device.name" = "alsa_card.usb-046d_HD_Pro_Webcam_C920_6B10B2DF-02";
            }
          ];
          actions = {
            "update-props" = {
              "device.disabled" = true;
            };
          };
        }
      ];
    };
  };

  # services.pipewire.extraConfig.pipewire.jacksink = {
  #   "context.objects" = [
  #     {
  #       name = "jacksink";
  #       factory = "adapter";
  #       args = {
  #         "factory.name" = "support.null-audio-sink";
  #         "node.name" = "jack";
  #         "media.class" = "Audio/Sink";
  #         "object.linger" = true;
  #         "audio.position" = [
  #           "FL"
  #           "FR"
  #         ];
  #       };
  #     }
  #   ];
  # };

  # RNNoise filtering for microphone input
  services.pipewire.extraConfig.pipewire.libpipewire-module-filter-chain = {
    "context.modules" = [
      {
        name = "libpipewire-module-filter-chain";
        args = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";
          "filter.graph" = {
            nodes = [
              {
                type = "ladspa";
                name = "rnnoise";
                plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";

                label = "noise_suppressor_mono";
                control = {
                  "VAD Threshold (%)" = 75.0;
                  "VAD Grace Period (ms)" = 200;
                  "Retroactive VAD Grace (ms)" = 50;
                };
              }
            ];
          };
          "capture.props" = {
            "node.name" = "capture.rnnoise_source";
            "node.passive" = true;
            "audio.rate" = 48000;
          };
          "playback.props" = {
            "node.name" = "rnnoise_source";
            "media.class" = "Audio/Source";
            "audio.rate" = 48000;
          };
        };
      }
    ];
  };
}
