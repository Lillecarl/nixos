{ ... }:
rec
{
  # Allow root to map to LilleCarl user in LXD container
  users.users.root = {
    initialHashedPassword = "$6$cQj59HFxckoo6edO$K52bjvtmBAFVlUVdCoLCURYbXYW.SM461pR4sq9jK7c/v1qy8caVOCthu4jfHTdhFwXLVKwe6WjV2grmH1l0b/";
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
