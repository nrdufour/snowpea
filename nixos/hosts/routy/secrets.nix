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
        "update_tsig_key" = {
          mode = "0440";
          owner = "kea";
          group = "kea";
        };

        "tailscale_auth_key" = {
          mode = "0440";
          owner = "root";
          group = "root";
        };
      };
    };
  };
}