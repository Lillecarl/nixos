{ lib, config, ... }:
let
  setEnv = {
    TERM = "xterm-256color";
  };
  internalSSH = {
    user = "carl.hjerpe";
    forwardAgent = true;
    sendEnv = [
      "GIT_AUTHOR_NAME"
      "GIT_AUTHOR_EMAIL"
      "GIT_COMMITTER_NAME"
      "GIT_COMMITTER_EMAIL"
      "EMAIL"
    ];
    extraOptions = {
      PubkeyAcceptedKeyTypes = "+ssh-rsa";
      PubkeyAcceptedAlgorithms = "+ssh-rsa";
      HostkeyAlgorithms = "+ssh-rsa";
      KexAlgorithms = "+diffie-hellman-group1-sha1";
      Ciphers = "+3des-cbc";
      StrictHostKeyChecking = "accept-new";
    };
  };
in
{
  programs.ssh = lib.mkIf config.ps.terminal.enable {
    enable = true;

    forwardAgent = false;

    matchBlocks = {
      "10.0.0.0/8" = internalSSH;
      "172.16.0.0/12" = lib.hm.dag.entryAfter [ "10.0.0.0/8" ] internalSSH;
      "192.168.0.0/16" = lib.hm.dag.entryAfter [ "172.16.0.0/12" ] internalSSH;
      "*" = lib.hm.dag.entryAfter [ "192.168.0.0/16" ] {
        inherit setEnv;
      };
    };

    serverAliveInterval = 10;
    serverAliveCountMax = 6;

    extraConfig = ''
      ConnectTimeout 5
      StrictHostKeyChecking accept-new
    '';
  };
}
