{config, ...}:
let
  # leaseOption = {
  #   valid-lifetime = 86400;
  #   renew-timer = 43200; # 50% of valid lifetime
  #   rebind-timer = 75600; # 87.5% of valid lifetime
  # };
  commonDhcpOptions = [
    {
      name = "domain-name-servers";
      data = "10.0.0.1";
    }
    # {
    #   name = "time-servers";
    #   data = "192.168.10.1";
    # }
    {
      name = "domain-name";
      data = "internal";
    }
    {
      name = "domain-search";
      data = "internal";
    }
  ];
in
{

  # sops.secrets.ddns-tsig-key = {
  #   # TODO: poor secret name
  #   sopsFile = ../../../../secrets/users.yaml;
  # };

  services.kea.dhcp4 = {
    enable = true;

    settings = {
      rebind-timer = 2000;
      renew-timer = 1000;
      valid-lifetime = 4000;

      interfaces-config = {
        interfaces = [
          "lan0"
          "lab0"
          "lab1"
        ];
      };

      subnet4 = [
        (
          {
            id = 1;
            interface = "lan0";
            subnet = "10.0.0.1/24";
            pools = [ { pool = "10.0.0.100 - 10.0.0.200"; } ];
            option-data = [
              {
                name = "routers";
                data = "10.0.0.1";
              }
              # {
              #   # this allows clients to be discovered by omada-controller
              #   name = "capwap-ac-v4";
              #   data = "10.5.0.10";
              # }
            ] ++ commonDhcpOptions;
          }
          # // leaseOption
        )
      ];

    };
  };

}