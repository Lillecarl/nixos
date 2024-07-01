{ ... }:
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
            "br13"
          ];
        };

        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };

        subnet4 = [
          (
            let
              subPref = "10.13.37.";
            in
            {
              id = 1;
              subnet = "${subPref}0/24";
              pools = [
                {
                  pool = "${subPref}10 - ${subPref}250";
                  option-data = [
                    {
                      name = "routers";
                      data = "${subPref}1";
                    }
                    {
                      name = "domain-name-servers";
                      data = "1.1.1.1, 1.0.0.1";
                    }
                  ];
                }
              ];
            }
          )
        ];
      };
    };
  };
}
