{
  config,
  pkgs,
  ...
}:
{
  ## This module isn't in use anymore
  ## but kept as a reference

  # Enable timer
  systemd.timers."rsync-nfs-books" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts in the morning
      OnCalendar = "08:00";
      Unit = "rsync-nfs-books.service";
    };
  };

  systemd.services."rsync-nfs-books" = {
    script = ''
      #!/usr/bin/env bash

      mkdir -p /srv/backup/nfs/as-is/books
      cd /srv/backup/nfs/as-is/books
      /run/current-system/sw/bin/rsync -av --delete /tank/Books/. .
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}