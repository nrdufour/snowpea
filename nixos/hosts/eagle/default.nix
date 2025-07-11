{ pkgs, ... }: {
  imports = [
    # ./gitea
    ./forgejo
  ];

  # Note: this *MUST* be set, otherwise nothing will be
  # present at boot and you end up in emergency mode ...
  mySystem = {
    system.zfs = {
      enable = true;
      mountPoolsAtBoot = [ "tank" ];
    };
  };

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };

    "/boot/firmware" =
      {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
      };

  };

  networking = {
    hostName = "eagle";
    # Setting the hostid for zfs
    hostId = "8425e349";

    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 ];
    };
  };

  sops.defaultSopsFile = ../../../secrets/eagle/secrets.sops.yaml;

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "01:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };
}
