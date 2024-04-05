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
      # Don't waste space between prompts
      add_newline = false;
      # username@hostname
      username = lib.mkForce {
        format = "\\[[$user]($style)";
      };
      hostname = lib.mkForce {
        ssh_symbol = "@";
        format = "[$ssh_symbol$hostname]($style)\\] in ";
      };
      # We don't use terraform workspaces so don't consume the space
      terraform = {
        disabled = true;
      };
      # Don't need IP of remote hosts since they're very unlikely to run starship
      localip = {
        disabled = true;
      };
      # Show exit codes
      status = {
        disabled = false;
      };
      # Don't show time
      time = {
        disabled = false;
      };
      # Don't show k8s context, we manage them with direnv
      kubernetes = {
        disabled = false;
      };
      # Show sudo wizard when we've got cached sudo (security alert/risk/awareness)
      sudo = lib.mkForce {
        disabled = false;
        symbol = "🧙";
        format = "\\[[as$symbol]($style)\\]";
      };
      # Yay for direnv
      direnv = {
        disabled = false;
        format = "\\[[$symbol$allowed/$loaded]($style)\\]";
        symbol = "  ";
        allowed_msg = "";
        loaded_msg = "";
        unloaded_msg = "";
        not_allowed_msg = "";
        denied_msg = "";
      };
      # Display which shell we're in
      env_var.STARSHIP_SHELL = {
        format = "\\[[$symbol($env_value)]($style)\\]";
        style = "fg:green";
        symbol = "🐚";
      };
      # Color them, to match the rest of our system
      palette = "catppuccin_${catppuccinFlavour}";
    }
  ]);
in
{
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
