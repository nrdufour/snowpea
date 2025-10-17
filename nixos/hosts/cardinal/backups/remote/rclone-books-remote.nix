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
      # starts after restic books backup completes (restic starts at 9:00)
      OnCalendar = "11:00";
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
    after = [ "restic-backups-books.service" ];
    requires = [ "restic-backups-books.service" ];
  };

}