_:
{
  services.earlyoom = {
    enable = true;

    enableNotifications = true;
  };

  # Get notifications from the system bus
  services.systembus-notify.enable = true;
}
