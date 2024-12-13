{ pkgs
, config
, ...
}:
let
  firstUid = 1000;
in
{
  users = {
    enforceIdUniqueness = true;
    mutableUsers = false;

    users = {
      root = {
        linger = true;
        hashedPassword = "$6$A1y4JvtC5Y6aZJ.i$0mwrY3.MzxJHfCh4bacEJj9P0sQpBnv5uAdZmAmVNzHV5Q.vxK7Kby5Oj1SidNwipeiHrPOfU0UKeC.LhY1B41";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHZ3pA0vIXiKQuwfM1ks8TipeOxfDT9fgo4xMi9iiWr lillecarl@lillecarl.com"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF4AwtWUz3usygb2J6owsUJs4X2yTchIGZyI+VDE76tF"
        ];
        subUidRanges = [
          {
            count = 1;
            startUid = firstUid;
          }
        ];
        subGidRanges = [
          {
            count = 1;
            startGid = 1000;
          }
        ];
      };
    };
    groups = {
      uaccess = { };
    };
  };

  environment = {
    homeBinInPath = true;
    localBinInPath = true;
  };
}
