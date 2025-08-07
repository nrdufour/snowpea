{ 
  pkgs,
  config,
  ...
}:
let 
  image = "crocodilestick/calibre-web-automated:V3.1.2@sha256:b07135bbbcaf2fe93b40980a4948d59df81ec7a7dd9dafe32607678b7e3e9cac";
in 
 {

  users.users.cwa = {
    home = "/tank/cwa";
    group = "cwa";
    isSystemUser = true;
    uid = 911;
  };

  users.groups.cwa = {
    gid = 911;
  };

  # no secret just yet, but a placeholder
  sops.templates."cwa.env" = {
    owner = "cwa";
    content = ''
      TZ=America/New_York
    '';
  };

  virtualisation.oci-containers.containers."cwa" = {
    inherit image;
    environmentFiles = [
      config.sops.templates."cwa.env".path
    ];
    volumes = [
      "/tank/cwa/config:/config"
      "/tank/cwa/ingest:/cwa-book-ingest"
      "/tank/cwa/library:/calibre-library"
    ];
    ports = [ "8083:8083" ];
    extraOptions = [
      # Block container access to Amazon to prevent 503 errors causing container crash.
      # Awaiting resolution to https://github.com/janeczku/calibre-web/issues/2963
      "--add-host 'amazon.com:0.0.0.0'"
      "--add-host 'www.amazon.com:0.0.0.0'"
      "--add-host 'douban.com:0.0.0.0'"
      "--add-host 'www.douban.com:0.0.0.0'"
    ];
  };

  security.acme.certs = {
    "cwa.internal" = { };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."cwa.internal" = {
      serverName = "cwa.internal";
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 2g;
      '';
      locations."/".proxyPass = "http://localhost:8083";
    };
  };

}
