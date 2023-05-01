{ config
, ...
}:
{
  services.samba = {
    enable = true;

    nsswins = true;
    enableNmbd = true;
    enableWinbindd = true;
    shares = {
      public = {
        path = "/home/lillecarl/Documents";
        comment = "Linux documents";
        browseable = true;
        "guest ok" = false;
        "read only" = false;
      };
    };
  };
}
