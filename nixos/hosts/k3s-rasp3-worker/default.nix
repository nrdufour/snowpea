{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../../personalities/base
    ../../personalities/privateca
    ../../personalities/users

    ../../personalities/k3s-node/agent.nix
  ];

  # networking.hostName = "something";

  # For now ...
  networking.firewall = {
    enable = false;
  };

  sops.defaultSopsFile = ../../../secrets/k3s-worker/secrets.sops.yaml;
}