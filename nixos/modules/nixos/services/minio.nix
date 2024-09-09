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
      package = lib.mkPackageOption pkgs "minio" { };
      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/minio/data";
      };
      rootCredentialsFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
      };
      minioConsoleURL = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      minioS3URL  = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
  };

  config = mkIf cfg.enable {

    ## service

    services.minio = {
      enable = true;
      listenAddress = "0.0.0.0:${builtins.toString s3port}";
      consoleAddress = "0.0.0.0:${builtins.toString port}";
      region = "us-east-1";
      inherit (cfg) package;
      dataDir = [
        cfg.dataDir
      ];
      inherit (cfg) rootCredentialsFile;
    };

    systemd.services.minio = {
      environment = {
        MINIO_SERVER_URL = "https://${cfg.minioS3URL}";
        MINIO_BROWSER_REDIRECT_URL = "https://${cfg.minioConsoleURL}";
      };
    };

    ### Ingress
    services.nginx.virtualHosts = {
      "${cfg.minioConsoleURL}" = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          client_max_body_size 2g;
        '';
        locations."^~ /" = {
          proxyPass = "http://127.0.0.1:${builtins.toString port}";
          proxyWebsockets = true;
        };
      };
      "${cfg.minioS3URL}" = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          client_max_body_size 2g;
        '';
        locations."^~ /" = {
          proxyPass = "http://127.0.0.1:${builtins.toString s3port}";
        };
      };
    };

    security.acme.certs = {
      "minio.internal" = {};
      "s3.internal" = {};
    };

    ### firewall config

    networking.firewall.allowedTCPPorts = [
      port
      s3port
    ];

  };
}