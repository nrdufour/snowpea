{ config, lib, pkgs, ... }:

{
  # Enable Tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";  # Enable both client and server routing features
    extraUpFlags = [
      "--advertise-routes=10.1.0.0/24"  # Advertise only the 10.1.0.0/24 subnet
      "--accept-routes"  # Accept routes from other nodes
    ];
    authKeyFile = "${config.sops.secrets."tailscale_auth_key".path}";
  };

  # Open firewall for Tailscale
  networking.firewall = {
    # Allow Tailscale traffic
    allowedUDPPorts = [ 41641 ]; # Tailscale port
    trustedInterfaces = [ "tailscale0" ];
  };

  # Enable IP forwarding for subnet routing
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  # Configure systemd-networkd to ignore Tailscale interface for wait-online
  systemd.network.networks."99-tailscale" = {
    matchConfig.Name = "tailscale*";
    linkConfig.RequiredForOnline = "no";
  };

}