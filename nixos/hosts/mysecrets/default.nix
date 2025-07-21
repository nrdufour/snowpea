{ pkgs, ... }: {

  imports = [
    ./step-ca
    ./vaultwarden
    # ./knot-dns
  ];

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };

    "/boot/firmware" =
      {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
      };

    "/srv" =
      {
        device = "/dev/disk/by-id/usb-Samsung_Flash_Drive_FIT_0323222060006409-0:0";
        fsType = "ext4";
      };
  };

  networking.hostName = "mysecrets";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 53 ];
    allowedUDPPorts = [ 53 ];
  };

  sops.defaultSopsFile = ../../../secrets/mysecrets/secrets.sops.yaml;

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "02:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };
  
}
