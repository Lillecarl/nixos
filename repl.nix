let
  host = builtins.getEnv "HOST";
  user = builtins.getEnv "USER";
  self = builtins.getFlake (toString ./.);

  out = self // rec {
    bs = builtins;

    os = self.nixosConfigurations.${host};
    home = self.homeConfigurations.${"${user}@${host}"};

    pkgs = self.nixosConfigurations.${host}.pkgs;
    config = self.nixosConfigurations.${host}.config;
    lib = self.inputs.nixpkgs.lib;
    fsys = lib.filesystem;
    fset = lib.filesets;

    slib = import ./lib { inherit (self) outPath; inherit lib; };

    nub_home = self.homeConfigurations."lillecarl@nub";
    shitbox_home = self.homeConfigurations."lillecarl@shitbox";
  };
in
out //
{
  tmp = import ./repl_tmp.nix out;
}
