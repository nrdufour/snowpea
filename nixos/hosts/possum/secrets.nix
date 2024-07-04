{
  pkgs,
  config,
  ...
}:
{
  config = {
    sops = {
      defaultSopsFile = ../../../secrets/possum/secrets.sops.yaml;
      secrets = {
        "storage/minio/root-credentials" = {
          owner = config.users.users.minio.name;
          restartUnits = [ "minio.service" ];
        };
      };
    };
  };
}