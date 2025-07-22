{
  pkgs,
  config,
  ...
}:
{
  sops.secrets = {
    vaultwarden_admin_token = {};
    vaultwarden_smtp_password = {};
  };

  sops.templates."vaultwarden.env" = {
    # owner = "vaultwarden";
    content = ''
      DATABASE_URL="postgresql://vaultwarden:${config.sops.placeholder.vaultwarden_db_password}@localhost:5432/vaultwarden"
      ADMIN_TOKEN="${config.sops.placeholder.vaultwarden_admin_token}"

      SMTP_HOST="smtp.migadu.com"
      SMTP_PORT=465
      SMTP_SECURITY=force_tls
      SMTP_FROM="cloud@ptinem.casa"
      SMTP_USERNAME="cloud@ptinem.casa"
      SMTP_PASSWORD="${config.sops.placeholder.vaultwarden_smtp_password}"
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