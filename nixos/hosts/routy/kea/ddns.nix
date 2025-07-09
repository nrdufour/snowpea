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
      ddns-qualifying-suffix = "internal";
    };
    dhcp-ddns = {
      enable = true;
      settings =
        let
          dnsServer = [
            {
              ip-address = "10.0.0.53";
              port = 53;
            }
          ];
        in
        {
          tsig-keys = [
            {
              name = "update";
              algorithm = "hmac-sha256";
              secret-file = "${config.sops.secrets."update_tsig_key".path}";
            }
          ];
          forward-ddns = {
            ddns-domains = [
              {
                name = "internal.";
                key-name = "update";
                dns-servers = dnsServer;
              }
            ];
          };
          reverse-ddns = {
            ddns-domains = [
              {
                name = "10.in-addr.arpa.";
                key-name = "update";
                dns-servers = dnsServer;
              }
            ];
          };
        };
    };
  };
}