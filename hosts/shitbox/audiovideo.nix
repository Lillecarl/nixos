{ pkgs, ... }:
let
  PULSE_SERVER = "unix:///run/pulse/native";
in
{
  # Restream webcam to virtual camera
  boot.kernelModules = [
    "v4l2loopback"
  ];
  environment.variables = { inherit PULSE_SERVER; };
  systemd.globalEnvironment = { inherit PULSE_SERVER; };

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

  # RNNoise filtering for microphone input
  services.pipewire.extraConfig.pipewire.jacksink = {
    "context.objects" = [
      {
        name = "jacksink";
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "jack";
          "media.class" = "Audio/Sink";
          "object.linger" = true;
          "audio.position" = [
            "FL"
            "FR"
          ];
        };
      }
    ];
  };
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
