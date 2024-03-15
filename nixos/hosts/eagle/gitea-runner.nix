{ config, ... }:
{
  sops.secrets = {
    gitea_runner_token = {};
  };

  services.gitea-actions-runner = {
    instances = {
      eagle = {
        enable = true;
        name = "eagle";
        url = "https://git.internal/";
        tokenFile = config.sops.secrets.gitea_runner_token.path;
        labels = [
          "native:host"
        ];
      };
    };
  };
}