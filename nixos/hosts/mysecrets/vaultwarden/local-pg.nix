{
  pkgs,
  config,
  ...
}:
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "vaultwarden" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  address          auth-method
      local all       postgres                 peer
      local all       all                      md5
      host  all       all     127.0.0.1/32     md5
      host  all       all     ::1/128          md5
    '';
    dataDir = "/srv/postgresql/${config.services.postgresql.package.psqlSchema}";
    initialScript = config.sops.templates."init_script.sql".path;
  };

  services.postgresqlBackup = {
    enable = true;
    location = "/srv/backups/postgresql";
  };

  sops.secrets = {
    vaultwarden_db_password = {};
  };

  sops.templates."init_script.sql" = {
    owner = "postgres";
    content = ''
      CREATE ROLE vaultwarden WITH LOGIN PASSWORD '${config.sops.placeholder.vaultwarden_db_password}';
      GRANT ALL PRIVILEGES ON DATABASE vaultwarden TO vaultwarden;
      ALTER DATABASE vaultwarden OWNER TO vaultwarden;
    '';
  };
}