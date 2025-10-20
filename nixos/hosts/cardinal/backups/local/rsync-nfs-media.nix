{
  config,
  pkgs,
  ...
}:
{
  ## This module isn't in use anymore
  ## but kept as a reference
  
  # Enable timer
  systemd.timers."rsync-nfs-media" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts in the morning
      OnCalendar = "08:00";
      Unit = "rsync-nfs-media.service";
    };
  };

  systemd.services."rsync-nfs-media" = {
    script = ''
      #!/usr/bin/env bash

      mkdir -p /srv/backup/nfs/as-is/media
      cd /srv/backup/nfs/as-is/media
      /run/current-system/sw/bin/rsync -av --delete /tank/Media/. .
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}