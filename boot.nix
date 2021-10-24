{ config, pkgs, ... }:

{
  boot = {
    # 2021/07/09 latest kernel doesn't build with Nvidia, nvidia fuck you
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_latest;
    # required for ZFS to build
    zfs.enableUnstable = true;
    # Enable ZFS boot
    supportedFilesystems = [ "zfs" ];
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "e1000e" "bcma" "r8169" ];
    initrd.network = {
      # This will use udhcp to get an ip address.
      # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`, 
      enable = true;
      ssh = {
         enable = true;
         # To prevent ssh from freaking out because a different host key is used,
         # use a different port for initrd SSH
         port = 2222; 
         hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" "/etc/secrets/initrd/ssh_host_ed25519_key" ];
         # public ssh key used for login
         authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJ8ga6UB6EPJAWaarh9vr852SKl5aEfNIoiwEeb7m36yDGLLxA/lw5ZzRH6i+krJYnTnXTUY7GVRxkBtPYsTF9tGN10jb7gvtZ67wuAl5Sxnt5EkXZuDS4M5ygT8zeBw0iM0k5/6ALNEaG+3UOT8gmFSqh5QxCqookA2XTDMPH8iZNFxhI5nhxTwkQu9iC7nOXVwg2VZsZJeh3VC823lrNZysuNYb9dGxE35atyjR8DPp83U7MfBZn2ppWGphoHfbCcH+w/oAHOiSr0iA7Kg8AuyeYh8KlbewNDSH7v/5GNzFsno+y5X2xPTNupP0FaL0gRkz/yvdyJcuWJw2UDujVm6frAxh7CKcWg7Tb6QZN/4dHnwpNu+XcffLTwQjMModM6olEJqdhzHyC7G5+fUQo4ngfN73MflwONYE+/verAgQRFv2d4kGHR3KTjW2duij8j1DScjv2s1VTYFUh9wC241xnH49Q9BHu5Rso/74jBDJ06uMU3bzoQoFZ3EMUJf8= lillecarl@nixos
" ];
      };
      # this will automatically load the zfs password prompt on login
      # and kill the other prompt so boot can continue
      postCommands = ''
        echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
    };
  };
}
