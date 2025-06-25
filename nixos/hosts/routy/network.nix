{ pkgs, config, ... }: {

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
        address = [ "10.0.0.1/24" ];
        linkConfig.RequiredForOnline = "carrier";
      };

      "30-lab0" = {
        matchConfig.Name = "lab0";
        address = [ "10.1.0.1/24" ];
        linkConfig.RequiredForOnline = "carrier";
      };

      "30-lab1" = {
        matchConfig.Name = "lab1";
        address = [ "10.1.1.1/24" ];
        linkConfig.RequiredForOnline = "carrier";
      };
    };
  };

}