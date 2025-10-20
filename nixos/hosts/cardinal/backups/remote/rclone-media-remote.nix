{
  config,
  pkgs,
  ...
}:
{
  ## Manual-only service (no timer)
  ## Run with: systemctl start rclone-media-remote

  # No timer - manual execution only

  # Below script will use rclone to save the media to the remote S3 bucket
  systemd.services."rclone-media-remote" = {
    script = ''
      #!/usr/bin/env bash

      cd /srv/backup/nfs/restic/media
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone-remote-access.conf".path} sync . b2:nemoworld-backups-nfs/media -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}