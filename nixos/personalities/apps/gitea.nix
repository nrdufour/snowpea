{ pkgs, ... }: {
  services.gitea = {
    enable = true;
    appName = "The Garden";
    stateDir = "/srv/storage/apps/gitea";

    settings = {
      server = {
        DOMAIN = "git.home";
        PROTOCOL = "http"; # http for now ...
      };
    };

    package = pkgs.unstable.gitea;
    dump.enable = true;
  };

  environment.systemPackages = with pkgs; [
    unstable.gitea
  ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    #recommendedTlsSettings = true;
    
    virtualHosts."git.home" = {
      #enableACME = true;
      #forceSSL = true;
      locations."/".proxyPass = "http://localhost:3000/";
    };
  };
}