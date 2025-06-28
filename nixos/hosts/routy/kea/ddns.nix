{ config, ... }:
let
  keaddnsUser = "kea";
in
{
  # add user, needed to access the secret
  users = {
    users.${keaddnsUser} = {
      isSystemUser = true;
      group = keaddnsUser;
      extraGroups = [ "knot" ];
    };
    groups.${keaddnsUser} = { };
  };

  services.kea = {
    dhcp4.settings = {
      dhcp-ddns.enable-updates = true;
      ddns-replace-client-name = "when-not-present";
      ddns-update-on-renew = true; # always update when a lease is renewed, in case I lost the DNS server database
      ddns-override-client-update = true; # always generate ddns update request ignoring the client's wishes not to
      ddns-override-no-update = true; # same as above but for different client's wishes
      ddns-qualifying-suffix = "home.arpa";
    };
    dhcp-ddns = {
      enable = true;
      settings =
        let
          dnsServer = [
            {
              ip-address = "10.0.0.1";
              port = 53;
            }
          ];
        in
        {
          tsig-keys = [
            {
              name = "kea";
              algorithm = "hmac-sha512";
              secret-file = "${config.sops.secrets."knot_update_tsig_key".path}";
            }
          ];
          forward-ddns = {
            ddns-domains = [
              {
                name = "internal.";
                key-name = "kea";
                dns-servers = dnsServer;
              }
            ];
          };
          reverse-ddns = {
            ddns-domains = [
              # {
              #   name = "168.192.in-addr.arpa.";
              #   key-name = "kea";
              #   dns-servers = dnsServer;
              # }
              {
                name = "10.in-addr.arpa";
                key-name = "kea";
                dns-servers = dnsServer;
              }
            ];
          };
        };
    };
  };
}