{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    rclone
  ];

  # Enable timer
  systemd.timers."rclone-garage-forgejo" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts one hour after the dump
      OnCalendar = "07:00";
      Unit = "rclone-garage-forgejo.service";
    };
  };

  sops.secrets = {
    garage_forgejo_access_key = { };
    garage_forgejo_secret_key = { };
  };

  sops.templates."rclone-garage-forgejo.conf" = {
    owner = "root";
    content = ''
      [garage]
      type = s3
      provider = Other
      access_key_id = ${config.sops.placeholder.garage_forgejo_access_key}
      secret_access_key = ${config.sops.placeholder.garage_forgejo_secret_key}
      endpoint = http://cardinal.internal:3900/
      region = garage
    '';
  };

  # Below script will use rclone to save the forgejo dump files into minio
  systemd.services."rclone-garage-forgejo" = {
    script = ''
      #!/usr/bin/env bash

      mkdir -p /srv/backup/garage/forgejo-dump-backup
      cd /srv/backup/garage/forgejo-dump-backup
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone-garage-forgejo.conf".path} sync garage:forgejo-dump-backup . -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

}