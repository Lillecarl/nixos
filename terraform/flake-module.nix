{ self
, inputs
, pkgs
, withSystem
, ...
}:
{
  perSystem = { config, self', inputs', pkgs, system, ... }:
  let
      pkgs = inputs.nixpkgs.legacyPackages.${system}; 
      terraformConfiguration = inputs.terranix.lib.terranixConfiguration {
        inherit system;
        modules = [ ./config.nix ];
      };
      tfrun = command: toString (pkgs.writers.writeBash command ''
        if [[ -e ./terraform/config.tf.json ]]; then rm -f ./terraform/config.tf.json; fi
        cp ${terraformConfiguration} ./terraform/config.tf.json \
          && ${pkgs.terraform}/bin/terraform -chdir="./terraform" init \
          && ${pkgs.terraform}/bin/terraform -chdir="./terraform" ${command}
      '');
  in
  {
    apps = {
      apply = {
        type = "app";
        #program = toString (pkgs.writers.writeBash "apply" ''
        #  if [[ -e ./terraform/config.tf.json ]]; then rm -f ./terraform/config.tf.json; fi
        #  cp ${terraformConfiguration} ./terraform/config.tf.json \
        #    && ${pkgs.terraform}/bin/terraform -chdir="./terraform" init \
        #    && ${pkgs.terraform}/bin/terraform -chdir="./terraform" apply
        #'');
        program = tfrun "apply";
      };
      # nix run ".#destroy"
      destroy = {
        type = "app";
        #program = toString (pkgs.writers.writeBash "destroy" ''
        #  if [[ -e ./terraform/config.tf.json ]]; then rm -f ./terraform/config.tf.json; fi
        #  cp ${terraformConfiguration} ./terraform/config.tf.json \
        #    && ${pkgs.terraform}/bin/terraform init \
        #    && ${pkgs.terraform}/bin/terraform destroy
        #'');
        program = tfrun "destroy";
      };
    };
  };
}
