{ pkgs, ... }: {
  imports = [
    # ./gitea
    ./forgejo
  ];

  boot.zfs.extraPools = [ "tank" ];

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

    # "/srv/forgejo" =
    #   {
    #     device = "tank/forgejo";
    #     fsType = "zfs";
    #   };

    # "/srv/postgresql" =
    #   {
    #     device = "tank/postgresql";
    #     fsType = "zfs";
    #   };

    # "/var/lib/gitea-runner" =
    #   {
    #     device = "tank/gitea-runner";
    #     fsType = "zfs";
    #   };
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
