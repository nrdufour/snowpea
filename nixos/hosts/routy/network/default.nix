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
    wait-online.enable = true;

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