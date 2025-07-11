{ pkgs, ... }: {

  networking.hostName = "opi01";

  ## No need to add filesystem just yet (covered by nixos-rk3588)

  # Make opi01 the first master
  mySystem.services.k3s.isClusterInit = true;

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };
}
