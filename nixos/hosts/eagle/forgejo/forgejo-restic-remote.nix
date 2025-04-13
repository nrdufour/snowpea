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
      passwordFile    = config.sops.secrets."backups/common-restic/password".path;
      environmentFile = config.sops.secrets."backups/common-restic/env".path;

      timerConfig = {
        OnCalendar = "*-*-* 6:00:00";
        Persistent = true;
      };
    };

  };

  sops = {
    secrets = {
      "backups/forgejo-backups/repository" = {};
      # "backups/forgejo-backups/password" = {};
      # "backups/forgejo-backups/env" = {};

      "backups/common-restic/password" = {
        sopsFile = ../../../../secrets/common-remote-restic/secrets.sops.yaml;
      };
      "backups/common-restic/env" = {
        sopsFile = ../../../../secrets/common-remote-restic/secrets.sops.yaml;
      };
    };
  };

}