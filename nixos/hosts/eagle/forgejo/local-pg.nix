{
  pkgs,
  config,
  ...
}:
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "forgejo" ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  address          auth-method
      local all       all                      trust
      host  all       all     127.0.0.1/32     trust
      host  all       all     ::1/128          trust
    '';
    dataDir = "/srv/postgresql/${config.services.postgresql.package.psqlSchema}";
    initialScript = config.sops.templates."init_script.sql".path;
  };

  sops.secrets = {
    forgejo_db_password = {
      owner = "forgejo";
    };
  };

  sops.templates."init_script.sql" = {
    owner = "postgres";
    content = ''
      CREATE ROLE forgejo WITH LOGIN PASSWORD '${config.sops.placeholder.forgejo_db_password}';
      GRANT ALL PRIVILEGES ON DATABASE forgejo TO forgejo;
      ALTER DATABASE forgejo OWNER TO forgejo;
    '';
  };
}