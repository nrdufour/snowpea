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
    };

  };

  sops = {
    secrets = {
      "backups/books/repository" = {};

      "backups/local-restic/password" = {
        sopsFile = ../../../../../secrets/common-local-restic/secrets.sops.yaml;
      };
    };
  };

}