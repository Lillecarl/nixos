{ config
, lib
, ...
}:
with lib;
{
  options = {
    nonixos.files = mkOption {
      default = { };
      example = literalExpression ''
        { example-configuration-file =
            { source = "/nix/store/.../etc/dir/file.conf.example";
              mode = "0440";
            };
          "default/useradd".text = "GROUP=100 ...";
        }
      '';
      description = lib.mdDoc ''
        Set of files that have to be linked in {file}`/etc`.
      '';

      type = with types; attrsOf (submodule (
        { name, config, options, ... }:
        {
          options = {
            nonixenable = mkOption {
              type = types.bool;
              default = true;
              description = lib.mdDoc ''
              '';
            };

            target = mkOption {
              type = types.str;
              description = lib.mdDoc ''
                Name of symlink (relative to /).
                Defaults to the attribute name.
              '';
            };

            source = mkOption {
              type = types.path;
              description = lib.mdDoc ''
                Source file to link to target.
              '';
            };
          };

          config = {
            target = mkDefault name;
          };
        }
      ));
    };
  };
  config = { };
}
