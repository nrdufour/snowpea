{ config, lib, pkgs, ... }:

{
  # Configure Podman as the OCI containers backend (default in NixOS)
  # Hosts can override this (e.g., eagle uses Docker for Forgejo runners)
  virtualisation.oci-containers.backend = lib.mkDefault "podman";

  # Configure Podman with Docker Hub mirror
  # Only enable if Docker is not explicitly enabled (to avoid conflicts)
  virtualisation.podman = lib.mkIf (!config.virtualisation.docker.enable) {
    # Enable Podman for OCI containers
    enable = lib.mkDefault true;

    # Docker compatibility layer
    dockerCompat = lib.mkDefault true;

    # Default network settings
    defaultNetwork.settings.dns_enabled = true;
  };

  # Configure Docker daemon with mirror (for hosts that use Docker like eagle)
  virtualisation.docker.daemon.settings = lib.mkIf config.virtualisation.docker.enable {
    # Configure mirror for Docker Hub
    registry-mirrors = [ "https://mirror.gcr.io" ];
  };

  # Configure registry mirrors for Podman using registries.conf v2 format
  # This uses Google Container Registry mirror to cache Docker Hub images
  # Images are still referenced by their original Docker Hub names in configs
  #
  # Note: The built-in virtualisation.containers.registries uses v1 format
  # which doesn't support mirrors, so we directly configure registries.conf
  # This config is used by both Podman and Buildkit
  # We use mkForce to override the default NixOS-generated config
  environment.etc."containers/registries.conf".text = lib.mkForce ''
    # Version 2 configuration format
    unqualified-search-registries = ["docker.io"]

    # Configure mirror for Docker Hub
    # mirror.gcr.io is Google's public mirror for Docker Hub
    [[registry]]
    prefix = "docker.io"
    location = "docker.io"

    [[registry.mirror]]
    location = "mirror.gcr.io"
    pull-from-mirror = "digest-only"
  '';
}
