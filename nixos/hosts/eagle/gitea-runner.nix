{ config, pkgs, ... }:
{
  sops.secrets = {
    gitea_runner_token = {};
  };

  # For the runner
  virtualisation.docker.enable = true;

  #
  # Ref: https://github.com/colonelpanic8/dotfiles/blob/03346eeaeb68633a50d6687659cbcdf46d243d36/nixos/gitea-runner.nix#L20
  # 

  services.gitea-actions-runner = {
    instances = {
      eagle = let gitea-runner-directory = "/var/lib/gitea-runner"; in {
        settings = {
          cache = {
            enabled = true;
          };
          container = {
            workdir_parent = "${gitea-runner-directory}/workspace";
          };
          host = {
            workdir_parent = "${gitea-runner-directory}/action-cache-dir";
          };
        };
        enable = true;
        name = "eagle";
        url = "https://git.internal/";
        tokenFile = config.sops.secrets.gitea_runner_token.path;
        labels = [
          "native:host"
          "debian:docker://node:21-bookworm"
        ];
        hostPackages = with pkgs; [
          bash
          coreutils
          curl
          gawk
          git-lfs
          nixFlakes
          gitFull
          gnused
          nodejs
          wget
          docker
        ];
      };
    };
  };
}
