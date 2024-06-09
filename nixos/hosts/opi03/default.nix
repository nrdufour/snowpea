{ pkgs, ... }: {
  imports = [
  ];

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };

    # "/boot/firmware" =
    #   {
    #     device = "/dev/disk/by-label/FIRMWARE";
    #     fsType = "vfat";
    #   };

  };

  networking.hostName = "opi03";

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 80 443 ];
  # };

  # sops.defaultSopsFile = ../../../secrets/eagle/secrets.sops.yaml;
}
