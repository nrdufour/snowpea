{
  config,
  pkgs,
  ...
}:
{
  # Enable timer
  systemd.timers."rclone-garage-cloudnative-pg" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts in the morning
      OnCalendar = "08:00";
      Unit = "rclone-garage-cloudnative-pg.service";
    };
  };

  # Below script will use rclone to save the cloudnative-pg dump files into minio
  systemd.services."rclone-garage-cloudnative-pg" = {
    script = ''
      #!/usr/bin/env bash

      mkdir -p /srv/backup/garage/cloudnative-pg
      cd /srv/backup/garage/cloudnative-pg
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone-garage-read-all.conf".path} sync garage:cloudnative-pg . -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}