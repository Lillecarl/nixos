{ pkgs
, ...
}:
{

  services.gitlab = {
    enable = true;
    databasePasswordFile = pkgs.writeText "dbPassword" "Setting1.Aggregate.Feed";
    initialRootPasswordFile = pkgs.writeText "rootPassword" "Setting1.Aggregate.Feed";
    databaseCreateLocally = true;
    databaseUsername = "git";
    user = "git";
    group = "git";
    smtp = {
      enable = true;
      address = "localhost";
      port = 25;
    };
    secrets = {
      secretFile = pkgs.writeText "secret" "Aig5zaic";
      otpFile = pkgs.writeText "otpsecret" "Riew9mue";
      dbFile = pkgs.writeText "dbsecret" "we2quaeZ";
      jwsFile = pkgs.runCommand "oidcKeyBase" { } "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };
    extraConfig = {
      gitlab = {
        email_from = "gitlab-no-reply@example.com";
        email_display_name = "Example GitLab";
        email_reply_to = "gitlab-no-reply@example.com";
        default_projects_features = { builds = false; };
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      localhost = {
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";
}
