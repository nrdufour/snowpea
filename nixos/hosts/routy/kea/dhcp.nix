{config, ...}:
let
  leaseOption = {
    valid-lifetime = 4000;
    renew-timer = 1000;
    rebind-timer = 2000;
  };
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
  services.kea.dhcp4 = {
    enable = true;

    settings = {

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
            reservations = [
              {
                hostname = "tv01";
                ip-address = "10.0.0.10";
                hw-address = "54:3a:d6:46:26:04";
              }
              {
                hostname = "printer";
                ip-address = "10.0.0.20";
                hw-address = "2c:6f:c9:0d:d1:7d";
              }
              {
                # In the basement
                hostname = "eap01";
                ip-address = "10.0.0.201";
                hw-address = "40:ed:00:70:12:d2";
              }
              {
                # 2nd floor
                hostname = "eap02";
                ip-address = "10.0.0.202";
                hw-address = "50:91:e3:68:08:c4";
              }
              {
                hostname = "nemo-cell";
                hw-address = "00:d2:79:b1:02:98";
              }
              {
                hostname = "mac-work";
                hw-address = "ae:6c:be:5a:c7:4f";
              }
            ];
          }
          // leaseOption
        )
        (
          {
            id = 2;
            interface = "lab0";
            subnet = "10.1.0.1/24";
            pools = [ { pool = "10.1.0.100 - 10.1.0.200"; } ];
            option-data = [
              {
                name = "routers";
                data = "10.1.0.1";
              }
            ] ++ commonDhcpOptions;
            reservations = [
              {
                hostname = "mikrotik";
                ip-address = "10.1.0.10";
                hw-address = "48:a9:8a:af:b2:5f";
              }
              {
                hostname = "opi01";
                ip-address = "10.1.0.20";
                hw-address = "c0:74:2b:ff:37:fa";
              }
              {
                hostname = "opi02";
                ip-address = "10.1.0.21";
                hw-address = "c0:74:2b:ff:3b:93";
              }
              {
                hostname = "opi03";
                ip-address = "10.1.0.22";
                hw-address = "c0:74:2b:ff:3c:0f";
              }
              {
                hostname = "sparrow01";
                ip-address = "10.1.0.41";
                hw-address = "b8:27:eb:4a:a5:21";
              }
              {
                hostname = "sparrow02";
                ip-address = "10.1.0.42";
                hw-address = "b8:27:eb:36:15:63";
              }
              {
                hostname = "sparrow03";
                ip-address = "10.1.0.43";
                hw-address = "b8:27:eb:64:fe:e5";
              }
              {
                hostname = "sparrow04";
                ip-address = "10.1.0.44";
                hw-address = "b8:27:eb:6d:ba:af";
              }
              {
                hostname = "sparrow05";
                ip-address = "10.1.0.45";
                hw-address = "b8:27:eb:52:77:f8";
              }
              {
                hostname = "sparrow06";
                ip-address = "10.1.0.46";
                hw-address = "b8:27:eb:14:48:33";
              }
              {
                hostname = "raccoon00";
                ip-address = "10.1.0.30";
                hw-address = "dc:a6:32:f9:0a:7a";
              }
              {
                hostname = "raccoon01";
                ip-address = "10.1.0.31";
                hw-address = "dc:a6:32:f9:0b:0d";
              }
              {
                hostname = "raccoon02";
                ip-address = "10.1.0.32";
                hw-address = "dc:a6:32:f8:f3:21";
              }
              {
                hostname = "raccoon03";
                ip-address = "10.1.0.33";
                hw-address = "dc:a6:32:f9:1f:fc";
              }
              {
                hostname = "raccoon04";
                ip-address = "10.1.0.34";
                hw-address = "dc:a6:32:f9:20:9e";
              }
              {
                hostname = "raccoon05";
                ip-address = "10.1.0.35";
                hw-address = "dc:a6:32:f9:20:b2";
              }
              {
                hostname = "possum";
                ip-address = "10.1.0.60";
                hw-address = "dc:a6:32:f9:22:5f";
              }
              {
                hostname = "beacon";
                ip-address = "10.1.0.70";
                hw-address = "90:fb:a6:85:c5:4b";
              }
              {
                hostname = "elephant";
                ip-address = "10.1.0.80";
                hw-address = "00:08:9b:da:da:22";
              }
              {
                hostname = "eagle";
                ip-address = "10.1.0.90";
                hw-address = "e4:5f:01:9c:9a:f4";
              }
              {
                hostname = "mysecrets";
                ip-address = "10.1.0.99";
                hw-address = "d8:3a:dd:17:1e:1b";
              }
            ];
          }
          // leaseOption
        )
      ];

    };
  };

}