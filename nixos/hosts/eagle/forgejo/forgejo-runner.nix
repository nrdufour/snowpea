{ config, pkgs, ... }:
{
  sops.secrets = {
    forgejo_runner_token = { };
  };

  environment.systemPackages = with pkgs; [
    cachix
    lazydocker
    lazygit
    git
    nodejs_24 # required by actions such as checkout
    openssl
  ];

  # For cachix
  nix.settings.trusted-users = [ "root" "gitea-runner" ];

  # For the runner
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
    };
  };

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

      first = let gitea-runner-directory = "/var/lib/gitea-runner/first"; in {
        settings = {
          cache = {
            enabled = true;
          };
          # Both the container and host workdir parent has to be fully specified
          # to avoid some issues with relative path in typescript module resolution.
          container = {
            workdir_parent = "${gitea-runner-directory}/workspace";

            ## Allow some path to be mounted
            ## See https://gitea.com/gitea/act_runner/src/branch/main/internal/pkg/config/config.example.yaml#L87
            valid_volumes = ["/etc/ssl/certs/*"];
          };
          host = {
            workdir_parent = "${gitea-runner-directory}/action-cache-dir";
          };
          runner = {
            envs = {
              # This is needed because the user 'forgejo-runner' is dynamic
              # and therefore has no home directory.
              # Without HOME, docker will try to create /.docker directory instead.
              HOME = "${gitea-runner-directory}/home";

              # Trying to set the timezone properly
              TZ = "America/New_York";
            };
          };
        };
        enable = true;
        name = "first";
        url = "https://forge.internal/";
        tokenFile = config.sops.secrets.forgejo_runner_token.path;
        labels = [
          "native:host"
          "docker:docker://node:22-bookworm"
        ];
        hostPackages = with pkgs; [
          bash
          coreutils
          curl
          gawk
          git-lfs
          nixVersions.stable
          gitFull
          gnused
          nodejs_24
          wget
          docker
          gnutar
          gzip
        ];
      };

      second = let gitea-runner-directory = "/var/lib/gitea-runner/second"; in {
        settings = {
          cache = {
            enabled = true;
          };
          # Both the container and host workdir parent has to be fully specified
          # to avoid some issues with relative path in typescript module resolution.
          container = {
            workdir_parent = "${gitea-runner-directory}/workspace";
            
            ## Allow some path to be mounted
            ## See https://gitea.com/gitea/act_runner/src/branch/main/internal/pkg/config/config.example.yaml#L87
            valid_volumes = ["/etc/ssl/certs/*"];
          };
          host = {
            workdir_parent = "${gitea-runner-directory}/action-cache-dir";
          };
          runner = {
            envs = {
              # This is needed because the user 'forgejo-runner' is dynamic
              # and therefore has no home directory.
              # Without HOME, docker will try to create /.docker directory instead.
              HOME = "${gitea-runner-directory}/home";
              
              # Trying to set the timezone properly
              TZ = "America/New_York";
            };
          };
        };
        enable = true;
        name = "second";
        url = "https://forge.internal/";
        tokenFile = config.sops.secrets.forgejo_runner_token.path;
        labels = [
          "native:host"
          "docker:docker://node:22-bookworm"
        ];
        hostPackages = with pkgs; [
          bash
          coreutils
          curl
          gawk
          git-lfs
          nixVersions.stable
          gitFull
          gnused
          nodejs_24
          wget
          docker
          gnutar
          gzip
        ];
      };

    };
  };
}
