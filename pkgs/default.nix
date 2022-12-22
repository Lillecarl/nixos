# This is an overlay for defining custom packages.
final: prev: {
  # Zabbix agent 2 version 5.4.11 (The same one our zabbix host runs)
  vp_zabbix-agent2 = prev.callPackage ../pkgs/vp_zabbix-agent2 { };
}
