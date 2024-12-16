{
  self,
  inputs,
  withSystem,
  __curPos ? __curPos,
  ...
}:
let
  system = "aarch64-linux";
in
{
  flake =
    let
      lib = inputs.nixpkgs-lib.lib;
      filePath = ./hosts.json;
      fileData = builtins.readFile filePath;
      fileAttrs = builtins.fromJSON fileData;
      fileAttrsAnywhere = lib.mapAttrs' (
        k: v:
        lib.nameValuePair "${k}-anywhere" (
          v
          // {
            labels = v.labels // {
              anywhere = "yes";
            };
          }
        )
      ) fileAttrs;
      fileAttrsMerged = fileAttrs // fileAttrsAnywhere;
    in
    {
      inherit fileAttrsMerged;
      nixosConfigurations = builtins.mapAttrs (
        name: data:
        withSystem data.labels.arch (
          {
            config,
            pkgs,
            flakeloc,
            ...
          }:
          let
            specialArgs = {
              inherit inputs flakeloc self;
            };
          in
          inputs.nixpkgs.lib.nixosSystem {
            inherit pkgs;
            modules = [
              (
                { config, ... }:
                {
                  boot.tmp = {
                    useTmpfs = true;
                    tmpfsSize = "20G";
                  };
                  networking.hostName = name;
                  networking.firewall.enable = false;
                  services.openssh.enable = true;
                  programs.git.enable = true;
                  zramSwap = {
                    enable = true;
                    writebackDevice = config.disko.devices.disk.local.content.partitions.zramWriteback.device;
                  };
                  environment.systemPackages = [
                    pkgs.gitui
                  ];
                  ps.labels = data.labels;
                }
              )
              ./default.nix
            ];
            inherit specialArgs;
          }
        )
      ) fileAttrsMerged;

      deploy.nodes = builtins.mapAttrs (name: data: {
        hostname = data.ipv4_address;
        profiles.system = {
          user = "root";
          sshUser = "root";
          path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${name};
        };
      }) fileAttrs;

      # This is highly advised, and will prevent many possible mistakes
      # checks = builtins.mapAttrs (
      #   system: deployLib: deployLib.deployChecks self.deploy
      # ) inputs.deploy-rs.lib;
    };
}
