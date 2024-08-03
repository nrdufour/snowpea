{ config, pkgs, ... }:
{
  sops.secrets = {
    forgejo_runner_token = { };
  };

  # For the runner
  virtualisation.docker.enable = true;

  environment.etc."buildkit/buildkitd.toml".text = ''
    [registry."forge.internal"]
      http = true
      insecure = true
      ca=["/etc/ssl/certs/ca-certificates.crt"]
  '';

  #
  # Ref: https://github.com/colonelpanic8/dotfiles/blob/03346eeaeb68633a50d6687659cbcdf46d243d36/nixos/forgejo-runner.nix#L20
  # 

  services.gitea-actions-runner = {
    # It's forgejo, not gitea ;-)
    package = pkgs.forgejo-actions-runner;

    instances = {
      default = let forgejo-runner-directory = "/var/lib/gitea-runner"; in {
        settings = {
          cache = {
            enabled = true;
          };
          # Both the container and host workdir parent has to be fully specified
          # to avoid some issues with relative path in typescript module resolution.
          container = {
            workdir_parent = "${forgejo-runner-directory}/workspace";
          };
          host = {
            workdir_parent = "${forgejo-runner-directory}/action-cache-dir";
          };
          runner = {
            envs = {
              # This is needed because the user 'forgejo-runner' is dynamic
              # and therefore has no home directory.
              # Without HOME, docker will try to create /.docker directory instead.
              HOME = "${forgejo-runner-directory}/eagle";
            };
          };
        };
        enable = true;
        name = "default";
        url = "https://forge.internal/";
        tokenFile = config.sops.secrets.forgejo_runner_token.path;
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
          gnutar
          gzip
        ];
      };
    };
  };
}
