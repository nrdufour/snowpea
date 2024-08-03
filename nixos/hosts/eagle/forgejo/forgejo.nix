{
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
  forgejoPort = 4000;
in
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts.${cfg.settings.server.DOMAIN} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 2g;
      '';
      locations."/".proxyPass = "http://localhost:${toString srv.HTTP_PORT}";
    };
  };

  services.forgejo = {
    enable = true;
    stateDir = "/srv/forgejo";
    dump = {
      enable = true;
    };
    
    database = {
      type = "postgres";
      name = "forgejo";
      host = "localhost";
      user = "forgejo";
      passwordFile = config.sops.secrets.forgejo_db_password.path;
    };

    settings = {
      server = {
        DOMAIN = "forge.internal";
        # You need to specify this to remove the port from URLs in the web UI.
        ROOT_URL = "https://${srv.DOMAIN}/"; 
        HTTP_PORT = forgejoPort;
      };
      # You can temporarily allow registration to create an admin user.
      service.DISABLE_REGISTRATION = true; 
      # Add support for actions, based on act: https://github.com/nektos/act
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      # Sending emails is completely optional
      # You can send a test email from the web UI at:
      # Profile Picture > Site Administration > Configuration >  Mailer Configuration 
      # mailer = {
      #   ENABLED = true;
      #   SMTP_ADDR = "mail.example.com";
      #   FROM = "noreply@${srv.DOMAIN}";
      #   USER = "noreply@${srv.DOMAIN}";
      # };
    };
    # mailerPasswordFile = config.age.secrets.forgejo-mailer-password.path;
  };

  # age.secrets.forgejo-mailer-password = {
  #   file = ../secrets/forgejo-mailer-password.age;
  #   mode = "400";
  #   owner = "forgejo";
  # };

  security.acme.certs."forge.internal" = {};
  
}