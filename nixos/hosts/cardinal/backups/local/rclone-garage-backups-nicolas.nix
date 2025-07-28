{
  config,
  pkgs,
  ...
}:
{
  # Enable timer
  systemd.timers."rclone-garage-backups-nicolas" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # the actual backups-nicolas starts at 9am so a good deal after
      OnCalendar = "12:00";
      Unit = "rclone-garage-backups-nicolas.service";
    };
  };

  # Below script will use rclone to save the backups-nicolas dump files into minio
  systemd.services."rclone-garage-backups-nicolas" = {
    script = ''
      #!/usr/bin/env bash

      mkdir -p /srv/backup/garage/backups-nicolas
      cd /srv/backup/garage/backups-nicolas
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone-garage-read-all.conf".path} sync garage:backups-nicolas . -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}