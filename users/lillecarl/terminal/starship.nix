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

      # Color them, to match the rest of our system
      palette = "catppuccin_${catppuccinFlavour}";

      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$kubernetes"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$pijul_channel"
        "$docker_context"
        "$package"
        "$c"
        "$cmake"
        "$daml"
        "$dart"
        "$deno"
        "$dotnet"
        "$golang"
        "$helm"
        "$lua"
        "$nodejs"
        "$perl"
        "$php"
        "$pulumi"
        "$python"
        "$red"
        "$ruby"
        "$rust"
        "$terraform"
        "$typst"
        "$vagrant"
        "$zig"
        "$buf"
        "$nix_shell"
        "$conda"
        "$meson"
        "$spack"
        "$memory_usage"
        "$aws"
        "$gcloud"
        "$azure"
        "$direnv"
        "\\["
        "$env_var"
        "$shlvl"
        "\\]"
        "$crystal"
        "$custom"
        "$sudo"
        "$cmd_duration"
        "$line_break"
        "$jobs"
        "$battery"
        "$time"
        "$status"
        "$os"
        "$container"
        "$shell"
        "$character"
      ];

      # username@hostname
      username = lib.mkForce {
        format = "\\[[$user]($style)";
      };
      hostname = lib.mkForce
        {
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

      kubernetes = {
        disabled = false;
        detect_env_vars = [ "KUBECONFIG" ];
      };
      # Show how deep we're shelled
      shlvl = {
        disabled = false;
        format = "[$symbol\\(($shlvl)\\)]($style)";
        symbol = "";
      };
      # Show sudo wizard when we've got cached sudo (security alert/risk/awareness)
      sudo = lib.mkForce
        {
          disabled = false;
          symbol = "🧙";
          format = "\\[[as$symbol]($style)\\]";
        };
      directory = {
        fish_style_pwd_dir_length = 1;
      };
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
        format = "[$symbol($env_value)]($style)";
        style = "fg:green";
        symbol = "🐚";
      };
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
