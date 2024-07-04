{ 
  pkgs,
  config,
  ...
}: {
  imports = [
    ./secrets.nix
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
  };

  networking.hostName = "possum";

  mySystem = {
    system.zfs = {
      enable = true;
      mountPoolsAtBoot = [ "tank" ];
    };
    
    services.nfs.enable = true;

    services.minio = {
      enable = true;
      package = pkgs.unstable.minio;
      dataDir = "/tank/Apps/minio";
      rootCredentialsFile = config.sops.secrets."storage/minio/root-credentials".path;
      minioConsoleURL = "minio.internal";
      minioS3URL = "s3.internal";
    };
  };

}
