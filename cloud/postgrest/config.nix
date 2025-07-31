{ ... }:
{
  imports = [
    ../nix
  ];

  config = {
    state = "postgrest";
    remoteStates = [
      "keycloak-config"
      "pg-cluster-config"
      "stage1"
    ];
  };
}
