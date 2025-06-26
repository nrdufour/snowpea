{
  pkgs,
  ...
}: {
  # imports = [
  # ];

  services.knot = {
    enable = true;

    # keyFiles = [
    #   "/var/lib/knot/update.key"
    # ];

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
        }
      ];

      # acl = [
      #   {
      #     id = "update_acl";
      #     address = "192.168.0.0/16";
      #     action = ["query" "update" "notify" "transfer"];
      #     key = "update";
      #   }
      # ];

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