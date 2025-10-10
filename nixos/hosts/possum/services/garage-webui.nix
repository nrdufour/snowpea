{ 
  pkgs,
  config,
  ...
}:
let 
  image = "khairul169/garage-webui:1.1.0@sha256:17c793551873155065bf9a022dabcde874de808a1f26e648d4b82e168806439c";
in 
 {

  sops.templates."garage-webui.env" = {
    owner = "root";
    content = ''
      API_BASE_URL=http://possum.internal:3903
      S3_ENDPOINT_URL=http://possum.internal:3900
      API_ADMIN_KEY=${config.sops.placeholder.storage_garage_admin_token}
    '';
  };

  virtualisation.oci-containers.containers."garage-webui" = {
    inherit image;
    environmentFiles = [
      config.sops.templates."garage-webui.env".path
    ];
    volumes = [
      "/etc/garage.toml:/etc/garage.toml:ro"
    ];
    ports = [ "3909:3909" ];
  };

  security.acme.certs = {
    "ui.garage.internal" = { };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."ui.garage.internal" = {
      serverName = "ui.garage.internal";
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 2g;
      '';
      locations."/".proxyPass = "http://localhost:3909";
    };
  };

}
