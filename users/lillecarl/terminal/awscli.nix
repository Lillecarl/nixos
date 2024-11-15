{ pkgs
, ...
}:
{
  programs.awscli = {
    enable = true;
  };
}
