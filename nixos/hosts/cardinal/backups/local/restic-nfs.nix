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

    # media = {
    #   paths = [
    #     "/tank/Media"
    #   ];
      
    #   initialize = true;
    #   repositoryFile  = config.sops.secrets."backups/media/repository".path;
    #   passwordFile    = config.sops.secrets."backups/local-restic/password".path;

    #   timerConfig = {
    #     OnCalendar = "*-*-* 10:00:00";
    #     Persistent = true;
    #   };
    # };

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