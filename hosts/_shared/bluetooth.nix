_: {
  services.blueman.enable = true;

  hardware = {
    bluetooth = {
      enable = true;

      powerOnBoot = true;

      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    enableRedistributableFirmware = true;
  };
}
