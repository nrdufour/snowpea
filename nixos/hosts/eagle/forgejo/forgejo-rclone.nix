{ pkgs, config, ...}: {
  environment.systemPackages = with pkgs; [
    rclone
  ];

  # Enable timer
  systemd.timers."forgejo-dump-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts one hour after the dump
      OnCalendar = "05:31";
      Unit = "forgejo-dump-backup.service";
    };
  };

  sops.secrets = {
    forgejo_dump_bucket_access_key_id = { };
    forgejo_dump_bucket_secret_access_key = { };
  };

  sops.templates."rclone.conf" = {
    owner = "forgejo";
    content = ''
      [minio]
      type = s3
      provider = Minio
      access_key_id = ${config.sops.placeholder.forgejo_dump_bucket_access_key_id}
      secret_access_key = ${config.sops.placeholder.forgejo_dump_bucket_secret_access_key}
      endpoint = https://s3.internal
      region = main
    '';
  };

  # Below script will use rclone to save the forgejo dump files into minio
  systemd.services."forgejo-dump-backup" = {
    script = ''
      #!/usr/bin/env bash

      cd /srv/forgejo/dump
      find . -type f -ctime +30 -exec rm {} \;
      /run/current-system/sw/bin/rclone --config ${config.sops.templates."rclone.conf".path} sync . minio:forgejo-dump-backup -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "forgejo";
    };
  };

}