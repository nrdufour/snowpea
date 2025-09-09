{ lib, pkgs, config, ... }: {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./network
      ./secrets.nix
      ./kea
      ./knot
      # ./bind
      ./firewall.nix
      ./ddos-protection.nix
      ./adguardhome
    ];

  networking.domain = "internal";

  # Fix hostname resolution - use actual interface IP instead of 127.0.0.2
  # Override any automatic hostname generation with explicit mapping
  networking.hosts = {
    "10.0.0.1" = [ "routy.internal" "routy" ];
    "127.0.0.2" = lib.mkForce [ ];  # Remove any entries for 127.0.0.2
  };

  services.openssh.openFirewall = false;

  # Configure rsyslog to capture blocked connection attempts
  services.rsyslog = {
    enable = true;
    extraConfig = ''
      # Capture all blocked connection messages to separate log file
      :msg,contains,"BLOCKED-CONN:" /var/log/blocked-connections.log
      & stop
    '';
  };

  # Log rotation for blocked connections
  services.logrotate.settings.blocked-connections = {
    files = [ "/var/log/blocked-connections.log" ];
    frequency = "daily";
    rotate = 30;
    compress = true;
    delaycompress = true;
    missingok = true;
    notifempty = true;
    create = "644 root root";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    dig
    iftop      # Real-time bandwidth monitoring by connection
    nethogs    # Per-process bandwidth usage
    tcpdump    # Packet analysis for DDoS investigation
    ethtool    # Network interface statistics
    conntrack-tools # Connection tracking utilities
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };

}
