{
  pkgs,
  config,
  ...
}:
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "gitea" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
    dataDir = "/srv/postgresql/${config.services.postgresql.package.psqlSchema}";
    initialScript = config.sops.templates."init_script.sql".path;
  };

  sops.secrets = {
    gitea_db_password = { };
  };

  sops.templates."init_script.sql" = {
    owner = "postgres";
    content = ''
      CREATE ROLE gitea WITH LOGIN PASSWORD '${config.sops.placeholder.gitea_db_password}';
      GRANT ALL PRIVILEGES ON DATABASE gitea TO gitea;
      ALTER DATABASE gitea OWNER TO gitea;
    '';
  };
}