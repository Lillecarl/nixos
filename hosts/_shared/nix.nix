{ pkgs
, lib
, inputs
, config
, ...
}:
{
  # Use switch-to-configuration Rust implementation
  system.switch = {
    enable = false;
    enableNg = true;
  };

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      allow-import-from-derivation = true;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      keep-going = true;
      warn-dirty = false;

      system-features = [
        "kvm"
        "recursive-nix"
        "uid-range"
      ];

      experimental-features = [
        "auto-allocate-uids"
        "cgroups"
        "nix-command"
        "flakes"
        "impure-derivations"
        "recursive-nix"
        "fetch-closure"
      ];

      trusted-users = [
        "nix-ssh"
        "root"
        "@wheel"
      ];

      trusted-public-keys = [
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "rycee.cachix.org-1:TiiXyeSk0iRlzlys4c7HiXLkP3idRf20oQ/roEUAh/A="
        "viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      ];
      trusted-substituters = [
        "https://cachix.cachix.org"
        "https://nix-community.cachix.org"
        "https://rycee.cachix.org"
        "https://viperml.cachix.org"
        "https://niri.cachix.org"
      ];
    };
    registry = {
      nixpkgs = { flake = inputs.nixpkgs; };
    };
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
    #registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    #nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    sshServe = {
      enable = true;
      write = true;
      protocol = "ssh-ng";
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHZ3pA0vIXiKQuwfM1ks8TipeOxfDT9fgo4xMi9iiWr lillecarl@lillecarl.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6+IWwqGjVoXHcNR5Z5H2r7RYDQ0BzvPbl/RXeDnidv root@nub"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUmhT3THV21iW0N8L8jx0DhOMkVHcJGF6I5tXeeBx6F root@shitbox"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINw+gQAy/GkwGFzmwhYCX/hWQbaLIZk5uePDmdW3i7gM lillecarl@nub"
      ];
    };
  };

  services.nix-serve = {
    enable = true;
    openFirewall = true;
  };
}
