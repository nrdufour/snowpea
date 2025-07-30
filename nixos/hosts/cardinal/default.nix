{ pkgs, config, ... }: {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./secrets.nix
      ./garage
      ./backups
      ./jellyfin.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Constraining the ZFS memory usage for ARC
  boot.extraModprobeConfig = ''
    options zfs zfs_arc_max=4294967296
  '';

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

  services.nfs.server = {
    enable = true;
    # Avoid using sharenfs settings in ZFS
    exports = ''
      /tank/Books 10.0.0.0/8(all_squash,insecure,sync,no_subtree_check,anonuid=1000,anongid=1000)
      /tank/Media 10.0.0.0/8(all_squash,insecure,sync,no_subtree_check,anonuid=1000,anongid=1000)
    '';
  };

  mySystem = {
    system.zfs = {
      enable = true;
      mountPoolsAtBoot = [ "tank" ];
    };

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
