{ pkgs, config, ... }: {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./secrets.nix
      ./garage
      ./backups
      ./jellyfin.nix
      ./cwa.nix
      ./navidrome.nix
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
      /tank/Books 10.0.0.0/8(all_squash,rw,insecure,sync,no_subtree_check,anonuid=1000,anongid=1000)
      /tank/Media 10.0.0.0/8(all_squash,rw,insecure,sync,no_subtree_check,anonuid=1000,anongid=1000)
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

  # To fix asymetric network issues
  systemd.services.policy-routing = {
    description = "Setup policy routing for dual-homed interfaces";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      ${pkgs.iproute2}/bin/ip rule add from 10.1.0.65 table 100 || true
      ${pkgs.iproute2}/bin/ip route add default via 10.1.0.1 dev enp1s0 table 100 || true
      
      ${pkgs.iproute2}/bin/ip rule add from 10.0.0.30 table 101 || true
      ${pkgs.iproute2}/bin/ip route add default via 10.0.0.1 dev enp2s0 table 101 || true
    '';
    
    preStop = ''
      ${pkgs.iproute2}/bin/ip rule del from 10.1.0.65 table 100 || true
      ${pkgs.iproute2}/bin/ip route flush table 100 || true
      
      ${pkgs.iproute2}/bin/ip rule del from 10.0.0.30 table 101 || true
      ${pkgs.iproute2}/bin/ip route flush table 101 || true
    '';
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };
}
