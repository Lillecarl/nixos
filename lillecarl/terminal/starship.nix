{ inputs
, lib
, pkgs
, ...
}:
let
  catppuccinFlavour = "mocha";

  presets = [
    "nerd-font-symbols"
    "bracketed-segments"
  ];
  presetFiles = (builtins.map
    (
      name: pkgs.runCommandLocal "starship_${name}" { } ''
        ${pkgs.starship}/bin/starship preset ${name} > $out
      ''
    )
    presets)
  ++
  [
    "${inputs.catppuccin-starship}/palettes/${catppuccinFlavour}.toml"
  ];

  presetListAttrs = builtins.map
    (
      config: builtins.fromTOML (builtins.readFile config)
    )
    presetFiles;

  presetsCfg = lib.mkMerge (presetListAttrs ++ [
    {
      # We don't use terraform workspaces so don't consume the space
      terraform = {
        disabled = true;
      };

      # Show exit codes
      status = {
        disabled = false;
      };

      time = {
        disabled = false;
      };

      kubernetes = {
        disabled = false;
      };

      sudo = {
        disabled = false;
      };

      # Display which shell we're in
      env_var.STARSHIP_SHELL = {
        format = "\\[[$symbol($env_value)]($style)\\]";
        style = "fg:green";
        symbol = "🐚";
      };

      palette = "catppuccin_${catppuccinFlavour}";
    }
  ]);
in
{
  home.file."debug".text = builtins.toJSON presetsCfg;

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableIonIntegration = true;

    settings = presetsCfg;
  };
}
