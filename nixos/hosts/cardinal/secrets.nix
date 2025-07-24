{
  pkgs,
  config,
  ...
}:
{
  config = {
    sops = {
      defaultSopsFile = ../../../secrets/cardinal/secrets.sops.yaml;
    };
  };
}