{ pkgs, config, ... }: {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "cardinal";
    # Setting the hostid for zfs
    hostId = "5f0cf156";

    # firewall = {
    #   enable = true;
    #   allowedTCPPorts = [ 80 443 3900 3902 3903 ];
    # };
  };

  mySystem = {
    system.zfs = {
      enable = true;
      # mountPoolsAtBoot = [ "tank" ];
    };
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };
}
