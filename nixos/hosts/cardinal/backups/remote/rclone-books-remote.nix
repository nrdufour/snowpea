{
  config,
  pkgs,
  ...
}:
{
  # Enable timer
  systemd.timers."rclone-books-remote" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts in the morning
      OnCalendar = "08:30";
      Unit = "rclone-books-remote.service";
    };
  };

  # Below script will use rclone to save the books to the remote S3 bucket
  systemd.services."rclone-books-remote" = {
    script = ''
      #!/usr/bin/env bash

      cd /srv/backup/nfs/restic/books
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone-remote-access.conf".path} sync . b2:nemoworld-backups-nfs/books -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}