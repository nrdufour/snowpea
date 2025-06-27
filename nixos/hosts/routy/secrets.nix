{
  pkgs,
  config,
  ...
}:
{
  config = {
    sops = {
      defaultSopsFile = ../../../secrets/routy/secrets.sops.yaml;
      secrets = {
        "knot_update_tsig_key" = {
          mode = "0440";
          owner = "knot";
          group = "knot";
          restartUnits = [ "knot.service" ];
        };
      };
    };
  };
}