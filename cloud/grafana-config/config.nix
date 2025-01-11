{ ... }:
{
  imports = [
    ../nix
  ];

  config = {
    state = "grafana-config";
    remoteStates = [
      "stage1"
      "keycloak-config"
    ];
  };
}
