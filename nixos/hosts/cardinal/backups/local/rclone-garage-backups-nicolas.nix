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

  sops.secrets = {
    garage_backups_nicolas_access_key = { };
    garage_backups_nicolas_secret_key = { };
  };

  sops.templates."rclone-garage-backups-nicolas.conf" = {
    owner = "root";
    content = ''
      [garage]
      type = s3
      provider = Other
      access_key_id = ${config.sops.placeholder.garage_backups_nicolas_access_key}
      secret_access_key = ${config.sops.placeholder.garage_backups_nicolas_secret_key}
      endpoint = http://cardinal.internal:3900/
      region = garage
    '';
  };

  # Below script will use rclone to save the backups-nicolas dump files into minio
  systemd.services."rclone-garage-backups-nicolas" = {
    script = ''
      #!/usr/bin/env bash

      mkdir -p /srv/backup/garage/backups-nicolas
      cd /srv/backup/garage/backups-nicolas
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone-garage-backups-nicolas.conf".path} sync garage:backups-nicolas . -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}