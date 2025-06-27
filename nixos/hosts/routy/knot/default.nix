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
          secret: ${config.sops.placeholder.knot_update_tsig_key}
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
        listen = "0.0.0.0@53";
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
        }
        # {
        #   domain = "s3.garage.internal";
        #   acl = "update_acl";
        # }
      ];

    };
  };
}