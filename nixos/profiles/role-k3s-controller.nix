{
  # For now ...
  networking.firewall = {
    enable = false;
  };

  sops.defaultSopsFile = ../../secrets/k3s-worker/secrets.sops.yaml;

  mySystem = {
    services.k3s = {
      enable = true;
      role = "server";
    };
  };
}