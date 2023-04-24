{ config
, lib
, pkgs
, ...
}:
let
  instanceType = "g6-nanode-1";
in
{
  terraform = {
    required_providers = {
      linode = {
        source = "linode/linode";
      };
    };
  };

  variable.LINODE_TOKEN = { };

  # Configure the Linode Provider
  provider.linode = {
    token = "\${var.LINODE_TOKEN}";
  };

  resource.linode_instance.foobar = {
    label = "cahj-linode";
    region = "eu-central";
    type = instanceType;
  };
}
