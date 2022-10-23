{ ... }:
rec
{
  # Allow root to map to LilleCarl user in LXD container
  users.users.root = {
    initialHashedPassword = "$6$ONUDqt1exFxDBPp.$mmPLQrgtFNJ543sZst.DoEAgVAyi5U8i2AWAXhDpoUGz0KDU.6QbXybsMtyPsMu5Q9nq2YKhfm5ca.oRHTVrm.";
    subUidRanges = [
      {
        count = 1;
        startUid = 1000;
        #startUid = users.users.lillecarl.uid;
      }
    ];
    subGidRanges = [
      {
        count = 1;
        startGid = 1000;
      }
    ];
  };
}
