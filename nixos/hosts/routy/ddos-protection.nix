{ config, pkgs, ... }: {

  # Create dedicated user for DDoS monitoring service
  users.users.ddos-monitor = {
    description = "DDoS Monitor Service User";
    isSystemUser = true;
    group = "ddos-monitor";
    home = "/var/empty";
    shell = "/run/current-system/sw/bin/nologin";
  };

  users.groups.ddos-monitor = {};

  # Create log directory for DDoS monitoring with dedicated user
  systemd.tmpfiles.rules = [
    "d /var/log/ddos 0755 ddos-monitor ddos-monitor -"
    "f /var/log/ddos/monitor.log 0644 ddos-monitor ddos-monitor -"
  ];

  # DDoS monitoring and response service
  systemd.services.ddos-monitor = {
    enable = true;
    description = "DDoS Attack Monitor for 940/880 Mbps Connection";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "systemd-tmpfiles-setup.service" ];
    wants = [ "systemd-tmpfiles-setup.service" ];
    
    serviceConfig = {
      Type = "simple";
      User = "ddos-monitor";
      Group = "ddos-monitor";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/log/ddos" ];
      PrivateTmp = true;
      Restart = "always";
      RestartSec = 30;
      
      # Additional security hardening
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RemoveIPC = true;
    };
    
    script = ''
      log_file="/var/log/ddos/monitor.log"
      
      echo "$(date): Starting DDoS monitor for 940/880 Mbps connection" >> "$log_file"
      
      while true; do
        # Get current network statistics
        if [ -r /sys/class/net/wan0/statistics/rx_bytes ] && [ -r /sys/class/net/wan0/statistics/tx_bytes ]; then
          RX_BYTES=$(cat /sys/class/net/wan0/statistics/rx_bytes 2>/dev/null || echo 0)
          TX_BYTES=$(cat /sys/class/net/wan0/statistics/tx_bytes 2>/dev/null || echo 0)
          
          sleep 5
          
          RX_BYTES_NEW=$(cat /sys/class/net/wan0/statistics/rx_bytes 2>/dev/null || echo 0)
          TX_BYTES_NEW=$(cat /sys/class/net/wan0/statistics/tx_bytes 2>/dev/null || echo 0)
          
          # Calculate bandwidth in Mbps
          RX_RATE=$(( ($RX_BYTES_NEW - $RX_BYTES) * 8 / 5 / 1000000 ))
          TX_RATE=$(( ($TX_BYTES_NEW - $TX_BYTES) * 8 / 5 / 1000000 ))
          
          # Monitor for high bandwidth usage - adjusted for 940/880 Mbps capacity
          # Alert at 85% of capacity: 799 Mbps download, 748 Mbps upload
          # This provides early warning while allowing normal high-bandwidth usage
          if [ $RX_RATE -gt 799 ] || [ $TX_RATE -gt 748 ]; then
            echo "$(date): HIGH BANDWIDTH ALERT (85%+ capacity) - RX: ''${RX_RATE}Mbps TX: ''${TX_RATE}Mbps" >> "$log_file"
            
            # Get detailed connection info during attack
            CONN_COUNT=$(${pkgs.procps}/bin/ss -ant 2>/dev/null | wc -l || echo "unknown")
            SYN_COUNT=$(${pkgs.procps}/bin/ss -ant state syn-sent 2>/dev/null | wc -l || echo "unknown")
            ESTAB_COUNT=$(${pkgs.procps}/bin/ss -ant state established 2>/dev/null | wc -l || echo "unknown")
            
            echo "$(date): Connection stats - Total: $CONN_COUNT, SYN: $SYN_COUNT, Established: $ESTAB_COUNT" >> "$log_file"
            
            # Log top connections by IP (if netstat available)
            if command -v ${pkgs.nettools}/bin/netstat > /dev/null; then
              echo "$(date): Top connection sources:" >> "$log_file"
              ${pkgs.nettools}/bin/netstat -an 2>/dev/null | ${pkgs.gawk}/bin/awk '/^tcp/ {print $5}' | ${pkgs.coreutils}/bin/cut -d: -f1 | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/uniq -c | ${pkgs.coreutils}/bin/sort -nr | ${pkgs.coreutils}/bin/head -5 >> "$log_file" 2>/dev/null || true
            fi
          fi
          
          # Check for excessive connection counts - scaled for gigabit capacity
          # Alert threshold increased to 10,000 connections to accommodate higher bandwidth usage
          # At gigabit speeds, more concurrent connections are normal and expected
          CONN_COUNT=$(${pkgs.procps}/bin/ss -ant 2>/dev/null | wc -l || echo 0)
          if [ $CONN_COUNT -gt 10000 ]; then
            echo "$(date): HIGH CONNECTION COUNT (potential attack): $CONN_COUNT connections" >> "$log_file"
          fi
          
        else
          echo "$(date): Warning - Cannot read wan0 network statistics" >> "$log_file"
          sleep 30  # Wait longer if interface not available
        fi
        
        sleep 5
      done
    '';
  };

  # Traffic shaping for DDoS mitigation
  systemd.services.traffic-shaping = {
    enable = true;
    description = "Traffic Shaping for DDoS Protection (800Mbps)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "systemd-networkd.service" ];
    wants = [ "systemd-networkd.service" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    
    script = ''
      # Wait for wan0 interface to be available
      for i in {1..30}; do
        if ${pkgs.iproute2}/bin/ip link show wan0 >/dev/null 2>&1; then
          break
        fi
        echo "Waiting for wan0 interface... ($i/30)"
        sleep 2
      done
      
      if ! ${pkgs.iproute2}/bin/ip link show wan0 >/dev/null 2>&1; then
        echo "ERROR: wan0 interface not found, skipping traffic shaping"
        exit 0
      fi
      
      # Clear existing rules
      ${pkgs.iproute2}/bin/tc qdisc del dev wan0 root 2>/dev/null || true
      ${pkgs.iproute2}/bin/tc qdisc del dev wan0 ingress 2>/dev/null || true
      
      # Ingress shaping (DDoS protection for 940 Mbps download)
      # Rate limit incoming traffic to 90% of capacity (846 Mbps) to prevent saturation
      # Burst allows temporary spikes up to 150MB to handle legitimate traffic bursts
      ${pkgs.iproute2}/bin/tc qdisc add dev wan0 ingress
      ${pkgs.iproute2}/bin/tc filter add dev wan0 parent ffff: protocol ip prio 1 u32 match ip src 0.0.0.0/0 police rate 846mbit burst 150mb drop
      
      # Egress shaping with QoS classes (880 Mbps upload capacity)
      # Root HTB qdisc with 90% of upload capacity (792 Mbps) to prevent bufferbloat
      # r2q=10 reduces quantum size for high-bandwidth classes (eliminates warnings)
      ${pkgs.iproute2}/bin/tc qdisc add dev wan0 root handle 1: htb default 30 r2q 10
      
      # Root class quantum 20000 prevents warning for the highest bandwidth class (792 Mbps)
      ${pkgs.iproute2}/bin/tc class add dev wan0 parent 1: classid 1:1 htb rate 792mbit quantum 20000
      
      # Priority traffic (DNS, SSH, ICMP, etc.) - 40% of capacity guaranteed, can burst to 75%
      # High priority ensures critical services remain responsive during attacks
      # quantum 10000 prevents "quantum is big" warning for high-bandwidth class
      ${pkgs.iproute2}/bin/tc class add dev wan0 parent 1:1 classid 1:10 htb rate 317mbit ceil 594mbit quantum 10000
      
      # Normal traffic (HTTP/HTTPS, regular applications) - 45% guaranteed, can use up to 70%
      # Adequate bandwidth for typical internet usage while preventing starvation
      # quantum 12000 prevents "quantum is big" warning for high-bandwidth class
      ${pkgs.iproute2}/bin/tc class add dev wan0 parent 1:1 classid 1:20 htb rate 357mbit ceil 554mbit quantum 12000
      
      # Bulk/default traffic (file transfers, P2P, unknown) - 15% guaranteed, max 50%
      # Ensures bulk traffic doesn't interfere with interactive services during attacks
      # quantum 5000 appropriate for lower bandwidth class
      ${pkgs.iproute2}/bin/tc class add dev wan0 parent 1:1 classid 1:30 htb rate 119mbit ceil 396mbit quantum 5000
      
      # Add fair queuing to each class
      ${pkgs.iproute2}/bin/tc qdisc add dev wan0 parent 1:10 handle 10: sfq perturb 10
      ${pkgs.iproute2}/bin/tc qdisc add dev wan0 parent 1:20 handle 20: sfq perturb 10
      ${pkgs.iproute2}/bin/tc qdisc add dev wan0 parent 1:30 handle 30: sfq perturb 10
      
      # Traffic classification filters
      # DNS traffic to priority class
      ${pkgs.iproute2}/bin/tc filter add dev wan0 parent 1: protocol ip prio 1 u32 match ip dport 53 0xffff flowid 1:10
      ${pkgs.iproute2}/bin/tc filter add dev wan0 parent 1: protocol ip prio 1 u32 match ip sport 53 0xffff flowid 1:10
      
      # SSH traffic to priority class  
      ${pkgs.iproute2}/bin/tc filter add dev wan0 parent 1: protocol ip prio 2 u32 match ip dport 22 0xffff flowid 1:10
      ${pkgs.iproute2}/bin/tc filter add dev wan0 parent 1: protocol ip prio 2 u32 match ip sport 22 0xffff flowid 1:10
      
      # HTTP/HTTPS to normal class
      ${pkgs.iproute2}/bin/tc filter add dev wan0 parent 1: protocol ip prio 3 u32 match ip dport 80 0xffff flowid 1:20
      ${pkgs.iproute2}/bin/tc filter add dev wan0 parent 1: protocol ip prio 3 u32 match ip dport 443 0xffff flowid 1:20
      
      echo "Traffic shaping configured for 940/880 Mbps connection with DDoS protection"
    '';
    
    preStop = ''
      # Clean up traffic shaping rules
      ${pkgs.iproute2}/bin/tc qdisc del dev wan0 root 2>/dev/null || true
      ${pkgs.iproute2}/bin/tc qdisc del dev wan0 ingress 2>/dev/null || true
    '';
  };

  # Log rotation for DDoS monitoring
  services.logrotate.settings.ddos-monitor = {
    files = [ "/var/log/ddos/monitor.log" ];
    frequency = "daily";
    rotate = 7;
    compress = true;
    delaycompress = true;
    missingok = true;
    notifempty = true;
    create = "644 ddos-monitor ddos-monitor";
  };

  # Emergency DDoS response script
  environment.systemPackages = with pkgs; [
    (writeScriptBin "ddos-emergency" ''
      #!/bin/sh
      
      if [ "$1" = "block" ]; then
        echo "EMERGENCY: Blocking all new WAN connections for 60 seconds..."
        
        # Add emergency rule to nftables using nft command
        ${pkgs.nftables}/bin/nft add rule inet nixos-fw nixos-fw-input iifname "wan0" ct state new drop comment \"ddos-emergency-block\"
        
        echo "Emergency block activated. Will auto-remove in 60 seconds."
        sleep 60
        
        # Remove emergency rule by comment
        ${pkgs.nftables}/bin/nft delete rule inet nixos-fw nixos-fw-input handle \$\(${pkgs.nftables}/bin/nft -a list chain inet nixos-fw nixos-fw-input | ${pkgs.gawk}/bin/awk '/ddos-emergency-block/ {print \$NF}'\)
        
        echo "Emergency block removed."
        
      elif [ "$1" = "status" ]; then
        echo "=== DDoS Protection Status ==="
        echo "Current connections:"
        ${pkgs.iproute2}/bin/ss -s
        echo ""
        echo "Current bandwidth utilization (last 5 seconds):"
        RX_BYTES=$(cat /sys/class/net/wan0/statistics/rx_bytes 2>/dev/null || echo 0)
        TX_BYTES=$(cat /sys/class/net/wan0/statistics/tx_bytes 2>/dev/null || echo 0)
        sleep 5
        RX_BYTES_NEW=$(cat /sys/class/net/wan0/statistics/rx_bytes 2>/dev/null || echo 0)
        TX_BYTES_NEW=$(cat /sys/class/net/wan0/statistics/tx_bytes 2>/dev/null || echo 0)
        RX_RATE=$(( ($RX_BYTES_NEW - $RX_BYTES) * 8 / 5 / 1000000 ))
        TX_RATE=$(( ($TX_BYTES_NEW - $TX_BYTES) * 8 / 5 / 1000000 ))
        RX_PERCENT=$(( $RX_RATE * 100 / 940 ))
        TX_PERCENT=$(( $TX_RATE * 100 / 880 ))
        echo "Download: ''${RX_RATE}Mbps (''${RX_PERCENT}% of 940Mbps capacity)"
        echo "Upload: ''${TX_RATE}Mbps (''${TX_PERCENT}% of 880Mbps capacity)"
        echo ""
        echo "Recent DDoS alerts:"
        tail -10 /var/log/ddos/monitor.log 2>/dev/null || echo "No log file found"
        
      else
        echo "DDoS Emergency Response Tool"
        echo "Usage: ddos-emergency {block|status}"
        echo ""
        echo "  block  - Emergency block all new WAN connections for 60s"
        echo "  status - Show current DDoS protection status"
      fi
    '')
  ];

}