{
  config,
  pkgs,
  ...
}:
{
  # Enable timer
  systemd.timers."rclone-media-remote" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts in the morning
      OnCalendar = "09:30";
      Unit = "rclone-media-remote.service";
    };
  };

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