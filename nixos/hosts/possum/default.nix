{ pkgs, ... }: {
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
  };

  networking.hostName = "possum";

  mySystem = {
    system.zfs.enable = true;
    services.nfs.enable = true;
    services.minio.enable = true;
  };

  sops.defaultSopsFile = ../../../secrets/possum/secrets.sops.yaml;
}
