{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../../base
    ../../users
    ../../apps/gitea.nix
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

}