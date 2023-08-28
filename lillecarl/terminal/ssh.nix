{ config
, pkgs
, inputs
, ...
}:
let
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
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;

    forwardAgent = false;

    matchBlocks = {
      "10.0.0.0/8" = internalSSH;
      "192.168.0.0/16" = internalSSH;
      "172.16.0.0/12" = internalSSH;
    };

    serverAliveInterval = 10;
    serverAliveCountMax = 6;
  };
}
