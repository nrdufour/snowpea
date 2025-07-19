{
  config,
  pkgs,
  ...
}:
{

  users.users.garage = {
    home = "/tank/Garage";
    group = "garage";
    isSystemUser = true;
  };

  users.groups.garage = {};

  sops = {
    secrets = {
      "storage_garage_rpc_key" = {};
      "storage_garage_admin_token" = {};
      "storage_garage_metric_token" = {};
      "update_tsig_key" = {};
    };
  };

  sops.templates."acme.env" = {
    content = ''
      RFC2136_TSIG_KEY=update
      RFC2136_TSIG_ALGORITHM=hmac-sha256.
      RFC2136_TSIG_SECRET="${config.sops.placeholder.update_tsig_key}"
      RFC2136_NAMESERVER=ns0.internal
    '';
  };

  sops.templates."garage.env" = {
    owner = "garage";
    content = ''
      GARAGE_RPC_SECRET=${config.sops.placeholder.storage_garage_rpc_key}
      GARAGE_ADMIN_TOKEN=${config.sops.placeholder.storage_garage_admin_token}
      GARAGE_METRICS_TOKEN=${config.sops.placeholder.storage_garage_metric_token}
    '';
  };

  # Add garage to migrate from minio
  services.garage = {
    enable = true;

    ## Package has to be explicitly setup
    # garage 1.2.0 (25.05)
    package = pkgs.garage_1_2_0;

    environmentFile = config.sops.templates."garage.env".path;
    
    settings = builtins.fromTOML ''
      metadata_dir = "/tank/Garage/metadata"
      data_dir = "/tank/Garage/data"
      db_engine = "lmdb"

      replication_factor = 1

      rpc_bind_addr = "[::]:3901"
      rpc_public_addr = "127.0.0.1:3901"
      # rpc_secret = "changeme"

      [s3_api]
      s3_region = "garage"
      api_bind_addr = "[::]:3900"
      root_domain = ".s3.garage.internal"

      [s3_web]
      bind_addr = "[::]:3902"
      root_domain = ".web.garage.internal"
      index = "index.html"

      [k2v_api]
      api_bind_addr = "[::]:3904"

      [admin]
      api_bind_addr = "[::]:3903"
      # admin_token = "changeme"
      # metrics_token = "changeme"
    '';
  };

  # Exposing Garage for s3 and web

  security.acme.certs = {
    "s3.garage.internal" = {
      domain = "s3.garage.internal";
      extraDomainNames = [
        # "foobar.s3.garage.internal"
        "*.s3.garage.internal"
      ];
      environmentFile = config.sops.templates."acme.env".path;
      dnsProvider = "rfc2136";
      # webroot has to be null if you use dnsProvider
      webroot = null;
    };
    "web.garage.internal" = { };
  };

  users.users.nginx.extraGroups = [ "acme" ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."s3.garage.internal" = {
      serverName = "s3.garage.internal";
      useACMEHost = "s3.garage.internal";
      forceSSL = true;
      # enableACME = true;
      extraConfig = ''
        client_max_body_size 10g;
      '';
      locations."/".proxyPass = "http://localhost:3900";
    };
    virtualHosts."*.s3.garage.internal" = {
      serverName = "~^(.*)\.s3\.garage\.internal$";
      useACMEHost = "s3.garage.internal";
      forceSSL = true;
      # enableACME = true;
      extraConfig = ''
        client_max_body_size 10g;
      '';
      locations."/".proxyPass = "http://localhost:3900";
    };
    virtualHosts."web.garage.internal" = {
      serverName = "web.garage.internal";
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 2g;
      '';
      locations."/".proxyPass = "http://localhost:3902";
    };
  };
}