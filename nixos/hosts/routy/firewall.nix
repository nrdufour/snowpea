{
  networking.firewall = {
    enable = true;

    trustedInterfaces = [
      "lan0"
      "lab0"
      "lab1"
      # "lan0.20"
      # "lan0.50"
      # "lan0.100"
     ];

    interfaces = {
      wan = {
        allowedTCPPorts = [
        ];
        allowedUDPPorts = [
        ];
      };
    };

    extraInputRules = ''
      # Anti-spoof/bogon from the Internet hitting WAN
      iifname "wan0" ip saddr {
        0.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8,
        169.254.0.0/16, 172.16.0.0/12, 192.0.2.0/24, 192.168.0.0/16,
        198.18.0.0/15, 224.0.0.0/4, 240.0.0.0/4
      } drop

      # ------------------------------
      # Absolutely never expose on WAN
      # ------------------------------

      # DNS (open resolvers = DDoS amplification)
      iifname "wan0" udp dport 53 drop
      iifname "wan0" tcp dport 53 drop

      # DHCP server (only LAN should serve DHCP)
      iifname "wan0" udp dport {67, 68} drop

      # NTP (common amplification target)
      iifname "wan0" udp dport 123 drop

      # SSDP / UPnP discovery (amplification + device leaks)
      iifname "wan0" udp dport 1900 drop

      # NetBIOS / SMB (classic worm targets, Windows sharing)
      iifname "wan0" tcp dport {139, 445} drop

      # Telnet (insecure remote shell, brute-forced constantly)
      iifname "wan0" tcp dport 23 drop

      # RDP (Windows Remote Desktop, major attack vector)
      iifname "wan0" tcp dport 3389 drop

      # VNC (remote GUI, often left unprotected)
      iifname "wan0" tcp dport {5900, 5901} drop

      # SNMP (device management, leaks configs if exposed)
      iifname "wan0" udp dport 161 drop

      # TFTP (trivial file transfer, rarely needed, exploited)
      iifname "wan0" udp dport 69 drop

      # mDNS (meant for local link only)
      iifname "wan0" udp dport 5353 drop

      # UPnP control ports (don’t advertise IGD on WAN)
      iifname "wan0" tcp dport {5000, 2869} drop

      # ------------------------------
      # ICMP (Ping) handling on WAN
      # ------------------------------
      # Allow echo requests (ping) but limit to 10 packets/sec
      # with a small burst to stay responsive under normal use.
      iifname "wan0" ip protocol icmp icmp type echo-request limit rate 10/second burst 20 accept

      # Drop all other ICMP echo requests on WAN
      iifname "wan0" ip protocol icmp icmp type echo-request drop
    '';
  };

  # Switching to nftables
  networking.nftables = {
    enable = true;
  };
}