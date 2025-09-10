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

      #### BLOCK commented out for now as it has its own issues
      #### Looks like it maybe having bad effects and no logging at all regarding blocked conns
      ####
      # # ------------------------------
      # # DDoS Protection (940/880 Mbps optimized) - Fixed for proper logging
      # # ------------------------------
      
      # # SYN flood protection - restructured to log properly
      # # Log all SYN packets that exceed rate limit (these are potential attacks)
      # iifname "wan0" tcp flags & (fin|syn|rst|ack) == syn limit rate 100/second burst 200 packets accept
      # iifname "wan0" tcp flags & (fin|syn|rst|ack) == syn log prefix "BLOCKED-CONN-SYN: " level info drop

      # # Connection limit per source IP - log violations  
      # iifname "wan0" ct count over 400 log prefix "BLOCKED-CONN-LIMIT: " level info drop
      
      # # Rate limit new connections globally - restructured for logging
      # # Allow legitimate traffic under rate limits, log and drop excess
      # iifname "wan0" ct state new limit rate 1000/second burst 2000 packets accept
      # iifname "wan0" ct state new log prefix "BLOCKED-CONN-RATE: " level info drop

      # # UDP flood protection - restructured for logging
      # iifname "wan0" ip protocol udp limit rate 500/second burst 1000 packets accept
      # iifname "wan0" ip protocol udp log prefix "BLOCKED-CONN-UDP: " level info drop

      # # Invalid TCP flag combinations (port scan protection) - add logging
      # iifname "wan0" tcp flags & (fin|syn|rst|psh|ack|urg) == fin|syn|rst|psh|ack|urg log prefix "BLOCKED-CONN-XMAS: " level info drop
      # iifname "wan0" tcp flags & (fin|syn|rst|ack) == 0 log prefix "BLOCKED-CONN-NULL: " level info drop

      # # Rate limit established connections - allow legitimate traffic
      # ct state established,related limit rate 2000/second burst 4000 packets accept
      
      # ------------------------------
      # Anti-spoof/bogon from the Internet hitting WAN
      # ------------------------------
      iifname "wan0" ip saddr {
        0.0.0.0/8, 10.0.0.0/8, 100.64.0.0/10, 127.0.0.0/8,
        169.254.0.0/16, 172.16.0.0/12, 192.0.2.0/24, 192.168.0.0/16,
        198.18.0.0/15, 224.0.0.0/4, 240.0.0.0/4
      } log prefix "BLOCKED-CONN-BOGON: " level info drop
      
      # ------------------------------
      # Absolutely never expose on WAN (Security-critical port blocking)
      # ------------------------------
      
      # DNS (open resolvers = DDoS amplification)
      # Block to prevent router being used as DNS amplification source
      # Legitimate DNS queries should go through ISP or configured resolvers
      iifname "wan0" udp dport 53 drop
      iifname "wan0" tcp dport 53 drop
      
      # DHCP server (only LAN should serve DHCP)
      # Prevents DHCP server from being accessible from internet
      # Ports 67 (server) and 68 (client) should never be exposed on WAN
      iifname "wan0" udp dport {67, 68} drop
      
      # NTP (common amplification target)
      # Network Time Protocol can be abused for DDoS amplification attacks
      # Internal devices should sync with internal NTP or through NAT
      iifname "wan0" udp dport 123 drop
      
      # SSDP / UPnP discovery (amplification + device leaks)
      # Simple Service Discovery Protocol exposes internal device information
      # Commonly abused for DDoS amplification attacks
      iifname "wan0" udp dport 1900 drop
      
      # NetBIOS / SMB (classic worm targets, Windows sharing)
      # Windows file sharing protocols, major malware vectors
      # Should never be exposed to internet due to security vulnerabilities
      iifname "wan0" tcp dport {139, 445} drop
      
      # Telnet (insecure remote shell, brute-forced constantly)
      # Unencrypted remote access protocol, replaced by SSH
      # Constant target for brute force attacks and exploitation
      iifname "wan0" tcp dport 23 drop
      
      # RDP (Windows Remote Desktop, major attack vector)
      # Frequently targeted for brute force and vulnerability exploitation
      # Should use VPN or SSH tunneling if remote access needed
      iifname "wan0" tcp dport 3389 drop
      
      # VNC (remote GUI, often left unprotected)
      # Virtual Network Computing, often has weak or no authentication
      # Common ports for VNC servers, should never be directly exposed
      iifname "wan0" tcp dport {5900, 5901} drop
      
      # SNMP (device management, leaks configs if exposed)
      # Simple Network Management Protocol can expose network configuration
      # Often uses default community strings, major information disclosure risk
      iifname "wan0" udp dport 161 drop
      
      # TFTP (trivial file transfer, rarely needed, exploited)
      # Trivial File Transfer Protocol has no authentication
      # Can be used to exfiltrate data or upload malware
      iifname "wan0" udp dport 69 drop
      
      # mDNS (meant for local link only)
      # Multicast DNS should only operate on local network segments
      # Can leak internal network information if exposed to internet
      iifname "wan0" udp dport 5353 drop
      
      # UPnP control ports (don't advertise IGD on WAN)
      # Universal Plug and Play control and presentation services
      # Should never be accessible from internet, can expose internal services
      iifname "wan0" tcp dport {5000, 2869} drop
      
      # ------------------------------
      # ICMP (Ping) handling on WAN
      # ------------------------------
      # Allow echo requests (ping) but limit to 10 packets/sec
      # with a small burst to stay responsive under normal use.
      iifname "wan0" ip protocol icmp icmp type echo-request limit rate 10/second burst 20 packets accept
      
      # Drop all other ICMP echo requests on WAN
      iifname "wan0" ip protocol icmp icmp type echo-request drop

      # ------------------------------
      # Logging and monitoring
      # ------------------------------
      # Log suspicious activity (rate limited to avoid log spam)
      iifname "wan0" limit rate 10/minute burst 5 packets log prefix "WAN-SUSPICIOUS: " level warn
    '';
  };

  # Switching to nftables
  networking.nftables = {
    enable = true;
  };
}