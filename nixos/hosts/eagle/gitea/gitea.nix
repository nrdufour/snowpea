{
  pkgs,
  config,
  ...
}:
{
  services.gitea = {
    enable = true;
    appName = "The Garden";
    stateDir = "/srv/gitea";

    settings = {
      server = {
        DOMAIN = "git.internal";
        PROTOCOL = "http";
        ROOT_URL = "https://git.internal/";
      };
    };

    package = pkgs.gitea;
    dump.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gitea
  ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."git.internal" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3000/";
      # to avoid error on file size
      extraConfig = ''
        client_max_body_size 2g;
      '';
    };
  };

  security.acme.certs."git.internal" = {};
}
