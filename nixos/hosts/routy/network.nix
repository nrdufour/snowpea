{ pkgs, config, ... }: {

  # Let's make sure we can forward traffic between the host and the router.
  boot = {
    kernel = {
      sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;
        # TODO: Configure IPV6
        "net.ipv6.conf.wan.disable_ipv6" = true;
        # "net.ipv6.conf.all.accept_ra" = 0;
        # "net.ipv6.conf.all.autoconf" = 0;
        # "net.ipv6.conf.all.use_tempaddr" = 0;
        # "net.ipv6.conf.wan.accept_ra" = 2;
        # "net.ipv6.conf.wan.autoconf" = 1;
      };
    };
  };

  networking = {
    hostName = "routy";
    domain   = "internal";
    useDHCP  = false;

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  services.resolved.enable = false;

  systemd.network = {
    enable = true;

    # Avoid blocking, even though we don't have NetworkManager enabled
    # in the same time
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

    netdevs = {
      # VLANs
      "20-lan0.20" = {
        netdevConfig = {
          Name = "lan0.20";
          Description = "HOME";
          Kind = "vlan";
        };
        vlanConfig.Id = 20;
      };
      "20-lan0.50" = {
        netdevConfig = {
          Name = "lan0.50";
          Description = "GUEST";
          Kind = "vlan";
        };
        vlanConfig.Id = 50;
      };
      "20-lan0.100" = {
        netdevConfig = {
          Name = "lan0.100";
          Description = "IOT";
          Kind = "vlan";
        };
        vlanConfig.Id = 100;
      };
    };

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
        address = [ "10.0.0.1/24" ];
        linkConfig.RequiredForOnline = "carrier";
        vlan = [
          "lan0.20" # HOME
          "lan0.50" # GUEST
          "lan0.100" # GUEST
        ];
      };

      "30-lab0" = {
        matchConfig.Name = "lab0";
        address = [ "10.1.0.1/24" ];
        linkConfig.RequiredForOnline = "carrier";
      };

      "30-lab1" = {
        matchConfig.Name = "lab1";
        address = [ "10.2.0.1/24" ];
        linkConfig.RequiredForOnline = "carrier";
      };

      # HOME VLAN
      "30-lan0.20" = {
        matchConfig.Name = "lan0.20";
        address = [ "10.0.20.1/24" ];
        linkConfig.RequiredForOnline = "routable";
      };

      # GUEST VLAN
      "30-lan0.50" = {
        matchConfig.Name = "lan0.50";
        address = [ "10.0.50.1/24" ];
        linkConfig.RequiredForOnline = "routable";
      };

      # IOT VLAN
      "30-lan0.100" = {
        matchConfig.Name = "lan0.100";
        address = [ "10.0.100.1/24" ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

}