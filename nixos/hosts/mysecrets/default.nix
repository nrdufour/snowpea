{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../../personalities/base
    ../../personalities/users
    ../../personalities/privateca
    ./step-ca
  ];

  networking.hostName = "mysecrets";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  # Disable bluetooth
  hardware.bluetooth.enable = false;
  hardware.bluetooth.powerOnBoot = false;
  boot.blacklistedKernelModules = [ "bluetooth" ];

  sops.defaultSopsFile = ../../../secrets/mysecrets/secrets.sops.yaml;
}