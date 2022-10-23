final: prev: {
  # keep sources this first
  sources = prev.callPackage (import ./_sources/generated.nix) { };
  # then, call packages with `final.callPackage`

  braveWaylandDesktopItem = prev.callPackage ./braveWayland.nix { };
  slackWaylandDesktopItem = prev.callPackage ./slackWayland.nix { };
  codeWaylandDesktopItem  = prev.callPackage ./codeWayland.nix { };
  xonsh-direnv            = prev.callPackage ./xonsh-direnv.nix { };
  xontrib-argcomplete     = prev.callPackage ./xontrib-argcomplete.nix { };
  tokenize-output         = prev.callPackage ./tokenize-output.nix { };
}
