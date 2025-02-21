{
  pkgs,
  config,
  ...
}:
{
  sops.templates."vaultwarden.env" = {
    # owner = "vaultwarden";
    content = ''
      DATABASE_URL="postgresql://vaultwarden:${config.sops.placeholder.vaultwarden_db_password}@localhost:5432/vaultwarden"
    '';
  };

  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    # backupDir = "TBD";
    environmentFile = config.sops.templates."vaultwarden.env".path;
    config = {
      DOMAIN = "https://bitwarden.internal";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."bitwarden.internal" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
      };
    };
  };
}