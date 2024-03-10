{ pkgs, ... }: {
  services.gitea = {
    enable = true;
    appName = "The Garden";
    stateDir = "/srv/storage/apps/gitea";

    settings = {
      server = {
        DOMAIN = "git2.home";
        PROTOCOL = "http";
        ROOT_URL = "https://git2.home/";
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
    recommendedTlsSettings = true;
    
    virtualHosts."git2.home" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:3000/";
    };
  };

	security.acme = {
    acceptTerms = true;
    defaults = {
      webroot = "/var/lib/acme/acme-challenge";
      server = "https://mysecrets.internal:8443/acme/acme/directory";
    };
		certs."git2.home" = {
			email = "nrdufour@gmail.com";
		};
	};
}