_:
{
  services.kea = {
    dhcp4 = {
      enable = true;
      settings = {
        rebind-timer = 600;
        renew-timer = 300;
        valid-lifetime = 1200;

        interfaces-config = {
          interfaces = [
            config.lib.lobr.name
          ];
        };

        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };

        subnet4 = [
          {
            id = 1;
            subnet = "${config.lib.lobr.network}/${config.lib.lobr.mask}";
            pools = [
              {
                pool = "${config.lib.lobr.first24}.10 - ${config.lib.lobr.first24}.250";
                option-data = [
                  {
                    name = "routers";
                    data = "${config.lib.lobr.first24}.1";
                  }
                  {
                    name = "domain-name-servers";
                    data = "1.1.1.1, 1.0.0.1";
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
