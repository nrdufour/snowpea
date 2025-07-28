{
  config,
  pkgs,
  ...
}:
{
  # Enable timer
  systemd.timers."rclone-garage-volsync-volumes" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts in the morning
      OnCalendar = "08:00";
      Unit = "rclone-garage-volsync-volumes.service";
    };
  };

  # Below script will use rclone to save the volsync-volumes dump files into minio
  systemd.services."rclone-garage-volsync-volumes" = {
    script = ''
      #!/usr/bin/env bash

      mkdir -p /srv/backup/garage/volsync-volumes
      cd /srv/backup/garage/volsync-volumes
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone-garage-read-all.conf".path} sync garage:volsync-volumes . -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}