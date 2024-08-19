{ pkgs, ... }: {
  imports = [
    # ./gitea
    ./forgejo
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
        device = "/dev/disk/by-label/EAGLE_ST";
        fsType = "ext4";
      };
  };

  networking = {
    hostName = "eagle";
    # Setting the hostid for zfs
    hostId = "8425e349";

    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  sops.defaultSopsFile = ../../../secrets/eagle/secrets.sops.yaml;
}
