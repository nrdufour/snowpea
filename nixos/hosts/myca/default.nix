{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    ../../personalities/base
    ../../personalities/users
    ../../personalities/apps/step-ca.nix
  ];

  networking.hostName = "myca";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  # For the yubikey
  environment.systemPackages = with pkgs; [
    yubikey-manager
  ];
  services.pcscd.enable = true;

  # Disable bluetooth
  hardware.bluetooth.enable = false;
  hardware.bluetooth.powerOnBoot = false;
}