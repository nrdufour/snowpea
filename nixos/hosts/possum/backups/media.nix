{ 
  pkgs,
  config,
  ...
}: {

  services.restic.backups = {

    media-backups = {
      paths = [
        "/tank/Media/Courses"
        "/tank/Media/Documentaries"
        "/tank/Media/Music"
        "/tank/Media/Music Videos"
        "/tank/Media/Music-to-sort"
        "/tank/Media/Pictures"
        "/tank/Media/Youtube"
        "/tank/Media/Shows"
        "/tank/Media/Movies-to-sort"
      ];
      
      initialize = true;
      repositoryFile  = config.sops.secrets."backups/media-backups/repository".path;
      passwordFile    = config.sops.secrets."backups/common-restic/password".path;
      environmentFile = config.sops.secrets."backups/common-restic/env".path;

      # extraOptions = [
      #   "s3.connections=20"
      # ];

      timerConfig = {
        OnCalendar = "*-*-* 2:00:00";
        Persistent = true;
      };
    };

  };

  sops = {
    secrets = {
      "backups/media-backups/repository" = {};

      "backups/common-restic/password" = {
        sopsFile = ../../../../secrets/common-remote-restic/secrets.sops.yaml;
      };
      "backups/common-restic/env" = {
        sopsFile = ../../../../secrets/common-remote-restic/secrets.sops.yaml;
      };
    };
  };


}