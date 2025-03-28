{ pkgs, ... }: {

  networking.hostName = "opi01";

  ## No need to add filesystem just yet (covered by nixos-rk3588)

  # Make opi01 the first master
  mySystem.services.k3s.isClusterInit = true;
}
