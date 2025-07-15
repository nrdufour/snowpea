{ 
  pkgs,
  config,
  ...
}:
let 
  image = "khairul169/garage-webui:1.0.9@sha256:7372ac2c8a2465ada40df26976a1eb1393e023554c5bb640a78f2a908c12e4fe";
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
