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

    firewall = {
      enable = false;
      # allowedTCPPorts = [ 80 443 3900 3902 3903 ];
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  mySystem = {
    system.zfs = {
      enable = true;
      mountPoolsAtBoot = [ "tank" ];
    };

    services.nfs.enable = true;

    services.samba = {
      enable = true;
      shares = {
        Books = {
          path = "/tank/Books";
          "read only" = "no";
        };
        Media = {
          path = "/tank/Media";
          "read only" = "no";
        };
      };
    };
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };
}
