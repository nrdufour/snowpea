{ 
  pkgs,
  config,
  ...
}: {
  imports = [
    ./secrets.nix
    ./backups
    # ./garage
    # ./services
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

  networking = {
    hostName = "possum";
    # Setting the hostid for zfs
    hostId = "05176a3c";

    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 3900 3902 3903 ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  mySystem = {
    system.zfs = {
      enable = true;
      mountPoolsAtBoot = [ "tank" ];
    };
    
    services.nfs.enable = true;

    services.minio = {
      enable = true;
      package = pkgs.unstable.minio;
      dataDir = "/tank/Minio";
      rootCredentialsFile = config.sops.secrets."storage/minio/root-credentials".path;
      minioConsoleURL = "minio.internal";
      minioS3URL = "s3.internal";
    };

    services.samba = {
      enable = true;
      shares = {
        Books = {
          path = "/tank/Books";
          "read only" = "no";
        };
        Media = {
          path = "/tank/Media";
          "read only" = "no";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
      rclone
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };

}
