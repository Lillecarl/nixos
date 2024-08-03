{ ... }:
{
  networking = {
    bridges = {
      # Bridge for VMs
      br13 = { interfaces = [ ]; };
    };
    interfaces = {
      br13 = {
        # Bridge address configuration
        ipv4.addresses = [{ address = "10.13.37.1"; prefixLength = 24; }];
      };
    };
  };
}
