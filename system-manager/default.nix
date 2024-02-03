_: {
  config = {
    nixpkgs.hostPlatform = "x86_64-linux";

    environment.etc = {
      "system-manager.conf.test".text = ''
        it works!!!!!
      '';
    };
  };
}
