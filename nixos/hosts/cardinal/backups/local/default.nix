{
  config,
  pkgs,
  ...
}:
{
  # Local backups via NFS onto elephant NAS

  imports =
    [
      ./rclone-garage-forgejo.nix
      ./rclone-garage-backups-nicolas.nix
      ./rclone-garage-cloudnative-pg.nix
      ./rclone-garage-volsync-volumes.nix
      ./rsync-nfs-books.nix
      ./rsync-nfs-media.nix
    ];

  environment.systemPackages = with pkgs; [
    rclone
  ];

  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true; # needed for NFS

  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
      what = "elephant.internal:/BackupGarage";
      where = "/srv/backup/garage";
    }
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
      what = "elephant.internal:/BackupNFS";
      where = "/srv/backup/nfs";
    }
  ];

  systemd.automounts = [
    {
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "300";
      };
      where = "/srv/backup/garage";
    }
    {
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "300";
      };
      where = "/srv/backup/nfs";
    }
  ];

  # Do not monitor the activity on /srv/backup/*
  services.prometheus.exporters.node.extraFlags = [
    "--collector.filesystem.mount-points-exclude=^/srv/backup/.*"
  ];

  sops.secrets = {
    garage_read_all_access_key = { };
    garage_read_all_secret_key = { };
  };

  sops.templates."rclone-garage-read-all.conf" = {
    owner = "root";
    content = ''
      [garage]
      type = s3
      provider = Other
      access_key_id = ${config.sops.placeholder.garage_read_all_access_key}
      secret_access_key = ${config.sops.placeholder.garage_read_all_secret_key}
      endpoint = http://cardinal.internal:3900/
      region = garage
    '';
  };
}