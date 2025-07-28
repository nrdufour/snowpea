{
  config,
  pkgs,
  ...
}:
{
  # Enable timer
  systemd.timers."rclone-garage-forgejo" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts one hour after the dump
      OnCalendar = "07:00";
      Unit = "rclone-garage-forgejo.service";
    };
  };

  # Below script will use rclone to save the forgejo dump files into minio
  systemd.services."rclone-garage-forgejo" = {
    script = ''
      #!/usr/bin/env bash

      mkdir -p /srv/backup/garage/forgejo-dump-backup
      cd /srv/backup/garage/forgejo-dump-backup
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone-garage-read-all.conf".path} sync garage:forgejo-dump-backup . -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}