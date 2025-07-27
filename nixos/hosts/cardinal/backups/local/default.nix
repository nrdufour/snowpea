{
  pkgs,
  ...
}:
{
  # Local backups via NFS onto elephant NAS

  imports =
    [
      ./rclone-garage-forgejo.nix
      ./rclone-garage-backups-nicolas.nix
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
}