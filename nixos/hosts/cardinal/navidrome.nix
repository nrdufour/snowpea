{
  pkgs,
  ...
}:
{
  services.navidrome = {
    enable = true;
    openFirewall = true;
  };

  security.acme.certs = {
    "navidrome.internal" = { };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."navidrome.internal" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 2g;
      '';
      locations."/".proxyPass = "http://localhost:4533";
    };
  };
}