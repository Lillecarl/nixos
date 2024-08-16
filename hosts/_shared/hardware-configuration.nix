{ config
, lib
, ...
}:
{
  boot = {
    kernelParams = [
      "delayacct"
    ];

    kernel.sysctl = {
      "kernel.task_delayacct" = 1;
      "net.ipv4.ip_forward" = lib.mkDefault 1;
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
      "vm.min_free_kbytes" = 151041; # 1% of RAM in nub
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = if config.networking.hostName == "nub" then 90 else 50;
    priority = config.disko.devices.lvm_vg.pool.lvs.swap.content.priority * 2;
    writebackDevice = "/dev/pool/${config.disko.devices.lvm_vg.pool.lvs.zram-writeback.name}";
  };
}
