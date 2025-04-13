{ 
  pkgs,
  config,
  ...
}: {

  services.restic.backups = {

    books-backups = {
      paths = [
        "/tank/Books"
      ];
      
      initialize = true;
      repositoryFile  = config.sops.secrets."backups/books-backups/repository".path;
      passwordFile    = config.sops.secrets."backups/common-restic/password".path;
      environmentFile = config.sops.secrets."backups/common-restic/env".path;

      timerConfig = {
        OnCalendar = "*-*-* 7:00:00";
        Persistent = true;
      };
    };

  };

  sops = {
    secrets = {
      "backups/books-backups/repository" = {};

      "backups/common-restic/password" = {
        sopsFile = ../../../../secrets/common-remote-restic/secrets.sops.yaml;
      };
      "backups/common-restic/env" = {
        sopsFile = ../../../../secrets/common-remote-restic/secrets.sops.yaml;
      };
    };
  };


}