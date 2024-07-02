{ lib, ... }:
{
  boot = {
    kernelParams = [
      "delayacct"
    ];

    kernel.sysctl = {
      "kernel.task_delayacct" = 1;
      "net.ipv4.ip_forward" = 1;
    };
  };

  environment.etc."lvm/lvm.conf".text = lib.mkForce ''
    devices {
      issue_discards = 1
    }
    allocations {
      thin_pool_discards = 1
    }
  '';
}
