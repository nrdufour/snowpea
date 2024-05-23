{ pkgs, config, ...}: {
  environment.systemPackages = with pkgs; [
    rclone
  ];

  # Enable timer
  systemd.timers."gitea-dump-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # starts one hour after the dump
      OnCalendar = "05:31";
      Unit = "gitea-dump-backup.service";
    };
  };

  sops.secrets = {
    gitea_dump_bucket_access_key_id = { };
    gitea_dump_bucket_secret_access_key = { };
  };

  sops.templates."rclone.conf" = {
    owner = "gitea";
    content = ''
      [minio]
      type = s3
      provider = Minio
      access_key_id = ${config.sops.placeholder.gitea_dump_bucket_access_key_id}
      secret_access_key = ${config.sops.placeholder.gitea_dump_bucket_secret_access_key}
      endpoint = https://s3.home
      region = main
    '';
  };

  # Below script will use rclone to save the gitea dump files into minio
  systemd.services."gitea-dump-backup" = {
    script = ''
      #!/usr/bin/env bash

      cd /srv/gitea/dump
      rclone --config ${config.sops.templates."rclone.conf".path} sync . minio:gitea-dump-backup -v
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "gitea";
    };
  };

}