{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../../personalities/base
    ../../personalities/privateca
    ../../personalities/users
    
    ./gitea.nix
  ];

  networking.hostName = "eagle";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

}