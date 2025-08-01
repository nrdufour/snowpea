{ pkgs, ... }: {

  networking.hostName = "opi03";

  ## No need to add filesystem just yet (covered by nixos-rk3588)

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };
}
