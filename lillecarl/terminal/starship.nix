{ inputs
, lib
, pkgs
, ...
}:
let
  catppuccinFlavour = "mocha";

  presets = [
    "nerd-font-symbols"
    "no-runtime-versions"
    #"no-empty-icons"
    #"bracketed-segments"
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

      # Directory config, truncation_length is subpath count not char count
      # don't truncate to git repo (not sure how i feel about this one yet)
      directory = {
        truncate_to_repo = false;
        truncation_length = 10;
      };

      # Show exit codes
      status = {
        disabled = false;
      };

      username = {
        format = "[$user]($style) on";
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
        format = " 🐚 [$env_value]($style) ";
        style = "fg:green";
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
