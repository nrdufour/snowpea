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

  services.bind = {
    enable = true;
    # forward = "only";
    forwarders = [
      # See https://www.joindns4.eu/for-public#resolver-options
      "86.54.11.1"
      "86.54.11.201"
      # Quad 9
      "9.9.9.9"
    ];
    listenOn = [
      "127.0.0.1"
      "10.0.0.1"
      "::1"
    ];
    # cacheNetworks = [
    #   "10.0.0.0/24"
    # ];
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
    };
  };

}