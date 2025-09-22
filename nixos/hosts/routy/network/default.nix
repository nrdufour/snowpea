{ pkgs, config, ... }: {

  imports =
    [
      # ./broadcast.nix
    ];

  # Let's make sure we can forward traffic between the host and the router.
  boot = {
    kernel = {
      sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
        # TODO: Configure IPV6
        "net.ipv6.conf.wan0.disable_ipv6" = true;
        # "net.ipv6.conf.all.accept_ra" = 0;
        # "net.ipv6.conf.all.autoconf" = 0;
        # "net.ipv6.conf.all.use_tempaddr" = 0;
        # "net.ipv6.conf.wan0.accept_ra" = 2;
        # "net.ipv6.conf.wan0.autoconf" = 1;

        # use TCP BBR has significantly increased throughput and reduced latency for connections
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";

        # ------------------------------
        # DDoS Protection & High-bandwidth optimization (940/880 Mbps)
        # ------------------------------
        
        # SYN flood protection - Enable TCP SYN cookies to handle SYN floods
        # SYN cookies allow the server to respond to SYN requests without storing connection state
        "net.ipv4.tcp_syncookies" = 1;
        
        # Increase SYN backlog to handle burst of legitimate connections at gigabit speeds
        # Higher value prevents dropping legitimate connections during traffic spikes
        "net.ipv4.tcp_max_syn_backlog" = 16384;
        
        # Reduce SYN-ACK retries to free up resources faster during attacks
        # Lower value prevents resource exhaustion from half-open connections
        "net.ipv4.tcp_synack_retries" = 2;
        
        # Reduce SYN retries for outgoing connections to fail faster
        # Prevents hanging connections from consuming resources
        "net.ipv4.tcp_syn_retries" = 5;
        
        # Connection tracking optimization for gigabit speeds (940/880 Mbps)
        # Max tracked connections - increased for high-bandwidth, high-connection scenarios
        # Each connection uses ~300 bytes, so 524288 connections ≈ 150MB RAM
        "net.netfilter.nf_conntrack_max" = 524288;
        
        # Reduce connection timeout to free up tracking slots faster
        # 5 minutes is sufficient for most applications while preventing exhaustion
        "net.netfilter.nf_conntrack_tcp_timeout_established" = 300;
        
        # Hash buckets for connection tracking - should be conntrack_max/4 for performance
        # More buckets = better hash distribution = faster lookups
        "net.netfilter.nf_conntrack_buckets" = 131072;
        
        # Buffer optimization for gigabit speeds + 2.5GbE NICs
        # Large receive buffers to handle high-bandwidth incoming traffic (940 Mbps)
        "net.core.rmem_max" = 1073741824;           # 1GB max receive buffer
        
        # Large send buffers to handle high-bandwidth outgoing traffic (880 Mbps)  
        "net.core.wmem_max" = 1073741824;           # 1GB max send buffer
        
        # Network device queue length - higher for 2.5GbE NICs to prevent packet drops
        # Increased backlog handles burst traffic without dropping packets
        "net.core.netdev_max_backlog" = 20000;
        
        # Network processing budget per NAPI poll - higher for gigabit throughput
        # More packets processed per interrupt = better efficiency at high speeds
        "net.core.netdev_budget" = 1000;
        
        # Time limit for network processing to prevent CPU starvation
        # Balanced value ensures network performance without blocking other tasks
        "net.core.netdev_budget_usecs" = 8000;
        
        # TCP performance tuning for gigabit speeds
        # TCP receive memory: min, default, max (in bytes)
        # Larger buffers handle high-bandwidth, high-latency connections better
        "net.ipv4.tcp_rmem" = "4096 131072 67108864";  # 64MB max receive
        
        # TCP send memory: min, default, max (in bytes)  
        # Large send buffers for efficient gigabit uploads (880 Mbps)
        "net.ipv4.tcp_wmem" = "4096 131072 67108864";  # 64MB max send
        
        # TCP memory allocation limits: low, pressure, high (in pages, 4KB each)
        # Increased for gigabit speeds to prevent memory pressure throttling
        "net.ipv4.tcp_mem" = "1572864 2097152 67108864";
        
        # Enable TCP TIME_WAIT socket reuse for high connection rate scenarios
        # Allows reuse of sockets in TIME_WAIT state for new connections
        "net.ipv4.tcp_tw_reuse" = 1;
        
        # Reduce FIN timeout to free up sockets faster during high connection turnover
        # Shorter timeout prevents socket exhaustion during attacks or high load
        "net.ipv4.tcp_fin_timeout" = 10;
      };
    };
  };

  networking = {
    hostName = "routy";
    domain   = "internal";
    useDHCP  = false;
    search   = [ "internal" ];


    ## Commenting out this section as the resolving is done
    ## via bind internals.
    # nameservers = [
    #   # Local DNS server
    #   "10.0.0.1"

    #   # dns4.eu
    #   # See https://www.joindns4.eu/for-public#resolver-options
    #   "86.54.11.1"
    #   "86.54.11.201"

    #   # Quad 9
    #   "9.9.9.9"
    # ];

    nat = {
      enable = true;
      internalInterfaces = [
        "lan0"
        "lab0"
        "lan1"
        # "lan0.20"
        # "lan0.50"
        # "lan0.100"
      ];
      externalInterface = "wan0";
    };
  };

  services.resolved.enable = false;

  systemd.network = {
    enable = true;

    # Enabling it after all, as long as we understand the fields `RequiredForOnline`
    # and `ActivationPolicy` used in the linkConfig below
    ## Ref: https://www.man7.org/linux/man-pages/man5/systemd.network.5.html
    wait-online.enable = false;

    links = {
      # rename all interface names to be easier to identify
      "10-wan0" = {
        matchConfig.Path = "pci-0000:01:00.0";
        linkConfig.Name = "wan0";
      };
      "10-lan0" = {
        matchConfig.Path = "pci-0000:02:00.0";
        linkConfig.Name = "lan0";
      };
      "10-lab0" = {
        matchConfig.Path = "pci-0000:03:00.0";
        linkConfig.Name = "lab0";
      };
      "10-lab1" = {
        matchConfig.Path = "pci-0000:04:00.0";
        linkConfig.Name = "lab1";
      };
    };

    # netdevs = {
    #   # VLANs
    #   "20-lan0.20" = {
    #     netdevConfig = {
    #       Name = "lan0.20";
    #       Description = "HOME";
    #       Kind = "vlan";
    #     };
    #     vlanConfig.Id = 20;
    #   };
    #   "20-lan0.50" = {
    #     netdevConfig = {
    #       Name = "lan0.50";
    #       Description = "GUEST";
    #       Kind = "vlan";
    #     };
    #     vlanConfig.Id = 50;
    #   };
    #   "20-lan0.100" = {
    #     netdevConfig = {
    #       Name = "lan0.100";
    #       Description = "IOT";
    #       Kind = "vlan";
    #     };
    #     vlanConfig.Id = 100;
    #   };
    # };

    networks = {
      "30-wan0" = {
        matchConfig.Name = "wan0";
        networkConfig.DHCP = "yes";
        linkConfig = {
          MTUBytes = "1500";
          RequiredForOnline = "routable";
        };
      };

      "30-lan0" = {
        matchConfig.Name = "lan0";
        address = [
          "10.0.0.1/24"
          "10.0.0.53/24"
          "10.0.0.54/24"
        ];
        # Configure even without carrier
        networkConfig = {
          ConfigureWithoutCarrier = true;
          KeepConfiguration = "static";
        };
        linkConfig = {
          ActivationPolicy  = "always-up";
          RequiredForOnline = "no";
        };
        # vlan = [
        #   "lan0.20"  # HOME
        #   "lan0.50"  # GUEST
        #   "lan0.100" # IOT
        # ];
      };

      "30-lab0" = {
        matchConfig.Name = "lab0";
        address = [
          "10.1.0.1/24"  # router
          "10.1.0.53/24" # authoritative dns
          "10.1.0.54/24" # adguard
        ];
        # Configure even without carrier
        networkConfig = {
          ConfigureWithoutCarrier = true;
          KeepConfiguration = "static";
        };
        linkConfig = {
          ActivationPolicy  = "always-up";
          RequiredForOnline = "no";
        };
      };

      "30-lab1" = {
        matchConfig.Name = "lab1";
        address = [
          "10.2.0.1/24"  # router
          "10.2.0.53/24" # authoritative dns
          "10.2.0.54/24" # adguard
        ];
        # Configure even without carrier
        networkConfig = {
          ConfigureWithoutCarrier = true;
          KeepConfiguration = "static";
        };
        linkConfig = {
          ActivationPolicy  = "always-up";
          RequiredForOnline = "no";
        };
      };

      # # HOME VLAN
      # "30-lan0.20" = {
      #   matchConfig.Name = "lan0.20";
      #   address = [ "10.0.20.1/24" ];
      #   linkConfig = {
      #     ActivationPolicy = "always-up";
      #     RequiredForOnline = "no";
      #   };
      # };

      # # GUEST VLAN
      # "30-lan0.50" = {
      #   matchConfig.Name = "lan0.50";
      #   address = [ "10.0.50.1/24" ];
      #   linkConfig = {
      #     ActivationPolicy = "always-up";
      #     RequiredForOnline = "no";
      #   };
      # };

      # # IOT VLAN
      # "30-lan0.100" = {
      #   matchConfig.Name = "lan0.100";
      #   address = [ "10.0.100.1/24" ];
      #   linkConfig = {
      #     ActivationPolicy = "always-up";
      #     RequiredForOnline = "no";
      #   };
      # };
    };
  };

}