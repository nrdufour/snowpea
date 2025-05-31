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
    };
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
    # garage 1.1.0 (25.05)
    package = pkgs.garage_1_1_0;

    environmentFile = config.sops.templates."garage.env".path;
    
    settings = builtins.fromTOML ''
      metadata_dir = "/tank/Garage/metadata"
      data_dir = "/tank/Garage/data"
      db_engine = "sqlite"

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
}