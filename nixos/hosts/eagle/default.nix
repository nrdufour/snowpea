{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../../personalities/base
    ../../personalities/privateca
    ../../personalities/users
    ../../personalities/node-exporter
    
    ./gitea.nix
    ./gitea-runner.nix
  ];

  networking.hostName = "eagle";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  sops.defaultSopsFile = ../../../secrets/eagle/secrets.sops.yaml;
}