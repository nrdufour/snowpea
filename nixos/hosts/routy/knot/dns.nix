{
  config,
  pkgs,
  ...
}: {
  # imports = [
  # ];

  sops.templates."knot_update_tsig_key" = {
    mode = "0440";
    owner = "knot";
    group = "knot";
    content = ''
      key:
        - id: update
          algorithm: hmac-sha256
          secret: ${config.sops.placeholder.update_tsig_key}
    '';
  };

  services.knot = {
    enable = true;

    ## TSIG keys to use
    ## Use "keymgr -t key-name hmac-sha256 > key-name.key"
    ## which would create the following content:
    ## key:
    ##   - id: key-name
    ##     algorithm: hmac-sha256
    ##     secret: <ACTUAL SECRET HERE>
    keyFiles = [
      config.sops.templates."knot_update_tsig_key".path
    ];

    settings = {
      server = {
        user = "knot:knot";
        listen = [
          "10.0.0.53@53"
          "10.1.0.53@53"
          # "10.2.0.53@53"
        ];
      };

      template = [
        {
          id = "default";
          storage = "/var/lib/knot";
          file = "%s.zone";
          semantic-checks = "on";
          acl = "update_acl";
        }
      ];

      acl = [
        {
          id = "update_acl";
          action = ["query" "update" "notify" "transfer"];
          key = "update";
        }
      ];

      zone = [
        {
          domain = "internal";

          ## With the following content in the file /var/lib/knot/internal.zone
          # internal.           	300	SOA	ns0.internal. nemo.ptinem.casa. 2025061403 14400 3600 1209600 3600
          # internal.           	300	A	10.0.0.1
          # internal.           	300	NS	ns0.internal.
          # internal.           	300	NS	ns1.internal.
          # internal.           	300	NS	ns2.internal.
          # ns0.internal.       	300	A	10.0.0.53
          # ns1.internal.       	300	A	10.1.0.53
          # ns2.internal.       	300	A	10.2.0.53
        }
        {
          domain = "10.in-addr.arpa";

          ## With the following content in the file /var/lib/knot/10.in-addr.arpa.zone
          # 10.in-addr.arpa.    	300	SOA	ns0.internal. nemo.ptinem.casa. 2025061307 14400 3600 1209600 3600
          # 10.in-addr.arpa.    	300	NS	ns0.internal.
          # 10.in-addr.arpa.    	300	NS	ns1.internal.
          # 10.in-addr.arpa.    	300	NS	ns2.internal.
        }
        { 
          domain = "s3.garage.internal";

          ## With the following content in the file /var/lib/knot/s3.garage.internal.zone
          # $ORIGIN s3.garage.internal.
          # $TTL 300
          # @   IN SOA ns0.internal. nemo.ptinem.casa. 1 14400 3600 1209600 3600
          #     IN NS  ns0.internal.
          #     IN NS  ns1.internal.
          #     IN NS  ns2.internal.         
        }
      ];

    };
  };
}