{ 
  pkgs,
  config,
  ...
}: {

  services.restic.backups = {

    books = {
      paths = [
        "/tank/Books"
      ];
      
      initialize = true;
      repositoryFile  = config.sops.secrets."backups/books/repository".path;
      passwordFile    = config.sops.secrets."backups/local-restic/password".path;

      timerConfig = {
        OnCalendar = "*-*-* 9:00:00";
        Persistent = true;
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
    };

    media = {
      paths = [
        "/tank/Media"
      ];
      
      initialize = true;
      repositoryFile  = config.sops.secrets."backups/media/repository".path;
      passwordFile    = config.sops.secrets."backups/local-restic/password".path;

      exclude = [
        # No point backing this up
        "/tank/Media/torrents"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 10:00:00";
        Persistent = true;
      };

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
    };
  };

  sops = {
    secrets = {
      "backups/books/repository" = {};
      "backups/media/repository" = {};

      "backups/local-restic/password" = {
        sopsFile = ../../../../../secrets/common-local-restic/secrets.sops.yaml;
      };
    };
  };

}