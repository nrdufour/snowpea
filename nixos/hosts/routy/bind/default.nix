{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  zoneSerial = toString inputs.self.lastModified;
in
{

  sops.templates."bind_update_tsig_key" = {
    mode = "0440";
    owner = "named";
    group = "named";
    content = ''
      key "update" {
        algorithm hmac-sha256;
        secret "${config.sops.placeholder.update_tsig_key}";
      };
    '';
  };

  # Ensure bind starts *after* the network is really online
  # otherwise, bind won't listen on other interfaces.
  systemd.services.bind.requires = ["network-online.target"];
  systemd.services.bind.after = ["network-online.target"];

  services.bind = {
    enable = true;

    ## Forwarding
    # forward = "first";
    forwarders = [
      # See https://www.joindns4.eu/for-public#resolver-options
      "86.54.11.1"
      "86.54.11.201"
      # Quad 9
      "9.9.9.9"
    ];

    # TODO: need to see is 0.0.0.0/0 might be better overall
    listenOn = [
      "127.0.0.1"
      "10.0.0.1"
      "::1"
    ];

    # Very important to *allow* the actual resolving of anything not local
    cacheNetworks = [
      "127.0.0.0/24"
      "::1/128"
      "10.0.0.0/24"
    ];

    extraOptions = ''
      dnssec-validation no;
    '';

    extraConfig = ''
      include "${config.sops.templates."bind_update_tsig_key".path}";
    '';

    zones = {
      "internal." = {
        master = true;
        extraConfig = ''
           allow-update { key "update"; };
           journal "${config.services.bind.directory}/db.internal.jnl";
        '';
        file = pkgs.writeText "internal" (
          lib.strings.concatStrings [
            ''
              $ORIGIN internal.
              $TTL    300
              @ IN SOA ns.internal. nemo.ptinem.casa (
              ${zoneSerial}           ; serial number
              3600                    ; refresh
              900                     ; retry
              1209600                 ; expire
              1800                    ; ttl
              )
                          IN    NS      ns.internal.
              ns          IN    A       10.0.0.1
            ''
          ]
        );
      };

      "10.in-addr.arpa." = {
        master = true;
        extraConfig = ''
           allow-update { key "update"; };
           journal "${config.services.bind.directory}/db.10.in-addr.arpa.jnl";
        '';
        file = pkgs.writeText "internal" (
          lib.strings.concatStrings [
            ''
              $ORIGIN 10.in-addr.arpa.
              $TTL    300
              @ IN SOA ns.internal. nemo.ptinem.casa (
              ${zoneSerial}           ; serial number
              3600                    ; refresh
              900                     ; retry
              1209600                 ; expire
              1800                    ; ttl
              )
                          IN    NS      ns.internal.
            ''
          ]
        );
      };
      
    };
  };

}