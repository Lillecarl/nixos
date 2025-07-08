{ kubenix, ... }:
{
  imports = [
    kubenix.modules.k8s
    kubenix.modules.helm
    kubenix.modules.submodule
    ./cilium.nix
    ./coredns.nix
    ./hcloud-ccm.nix
    ./local-path-provisioner.nix
    ./nginx.nix
  ];
}
