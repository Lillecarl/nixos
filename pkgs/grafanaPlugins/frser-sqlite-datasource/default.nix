{ grafanaPlugin, lib }:

grafanaPlugin {
  pname = "frser-sqlite-datasource";
  version = "3.3.2";
  zipHash = "sha256-h6/ZwRmAOKE0LuqhxZYN+E4F7i0NpcZ6Is4oMiZF6dI=";
  meta = with lib; {
    description = "Connects Grafana to sqlite";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
