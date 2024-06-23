{ lib
, config
, pkgs
, ...
}:
with lib;
let
  cfg = config.mySystem.services.minio;
  port = 9001; #int
  s3port = 9000; #int
in
{
  options.mySystem.services.minio = {
      enable = mkEnableOption "minio";
  };

  config = mkIf cfg.enable {

    ## Secrets
    sops.secrets.minio_root_creds = {
      restartUnits = [ "minio.service" ];
    };

    ## service

    services.minio = {
      enable = true;
      listenAddress = "0.0.0.0:${builtins.toString s3port}";
      consoleAddress = "0.0.0.0:${builtins.toString port}";
      region = "us-east-1";
      rootCredentialsFile = "${config.sops.secrets."${category}/${app}/env".path}";
      dataDir = [ "${config.mySystem.nasFolder}/minio" ]; #TBD
      configDir = "/var/lib/${app}"; #TBD
    };

    systemd.services.minio = {
      environment = {
        MINIO_SERVER_URL = "https://s3.${config.mySystem.internalDomain}";
        MINIO_BROWSER_REDIRECT_URL = "https://minio.${config.mySystem.internalDomain}";
      };
    };

    ### Ingress
    services.nginx.virtualHosts."minio.${config.mySystem.internalDomain}" = {
      forceSSL = true;
      locations."^~ /" = {
        proxyPass = "http://127.0.0.1:${builtins.toString port}";
        proxyWebsockets = true;
      };
    };
    services.nginx.virtualHosts."s3.${config.mySystem.internalDomain}" = {
      forceSSL = true;
      locations."^~ /" = {
        proxyPass = "http://127.0.0.1:${builtins.toString s3port}";
      };
    };

    ### firewall config

    networking.firewall.allowedTCPPorts = [
      port
      s3port
    ];

  };
}