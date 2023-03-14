{ config, pkgs, inputs, ... }:
{
  programs.starship = {
    enable = true;

    settings = {
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

      # Display which shell we're in
      # Do we actually need this? We use xonsh all the time.
      env_var.STARSHIP_SHELL = {
        format = "🐚 [$env_value]($style) ";
        style = "fg:green";
      };
    };
  };
}
