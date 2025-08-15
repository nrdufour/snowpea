{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    smcroute
    avahi
  ];

  # smcroute configuration: correct modern syntax
  environment.etc."smcroute.conf".text = ''
  phyint lan0 enable
  phyint lab0 enable

  # join SSDP multicast group on both interfaces
  mgroup from lan0 group 239.255.255.250
  mgroup from lab0 group 239.255.255.250

  # forward SSDP multicast between interfaces
  mroute from lan0 group 239.255.255.250 to lab0
  mroute from lab0 group 239.255.255.250 to lan0
  '';

  # smcroute service
  systemd.services.smcroute = {
    description = "Static Multicast Routing for SSDP (DLNA/UPnP)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.smcroute}/sbin/smcrouted -f /etc/smcroute.conf";
      Restart = "on-failure";
    };
  };

  # Avahi for mDNS reflection
  services.avahi = {
    enable = true;
    reflector = true;   # Reflect mDNS between interfaces
    ipv4 = true;
    ipv6 = false;
    publish = {
      enable = true;
      workstation = true;
    };
  };

  # Firewall rules for SSDP and mDNS
  networking.firewall.extraCommands = ''
    # Define multicast ports and addresses
    nft add rule inet filter input \
      iifname { "lan0", "lab0" } \
      udp dport { 1900, 5353 } \
      ip daddr { 239.255.255.250, 224.0.0.251 } \
      accept

    nft add rule inet filter forward \
      iifname { "lan0", "lab0" } \
      oifname { "lan0", "lab0" } \
      udp dport { 1900, 5353 } \
      ip daddr { 239.255.255.250, 224.0.0.251 } \
      accept
  '';
}
