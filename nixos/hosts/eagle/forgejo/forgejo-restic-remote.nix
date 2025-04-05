{ 
  pkgs,
  config,
  ...
}:
{

  services.restic.backups = {

    forgejo-backups = {
      paths = [
        "/srv/forgejo/dump"
      ];
      
      initialize = true;
      repositoryFile  = config.sops.secrets."backups/forgejo-backups/repository".path;
      passwordFile    = config.sops.secrets."backups/forgejo-backups/password".path;
      environmentFile = config.sops.secrets."backups/forgejo-backups/env".path;

      timerConfig = {
        OnCalendar = "*-*-* 6:00:00";
        Persistent = true;
      };
    };

  };

  sops = {
    secrets = {
        "backups/forgejo-backups/repository" = {};
        "backups/forgejo-backups/password" = {};
        "backups/forgejo-backups/env" = {};
    };
  };

}