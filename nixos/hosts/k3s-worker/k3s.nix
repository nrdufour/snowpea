{

  services.k3s.enable = true;

  # Agent by default for now
  services.k3s.role = "agent";
  services.k3s.extraFlags = toString [
    "--disable=local-storage"
    "--disable=traefik"
    "--disable=metrics-server"
  ];

  environment.systemPackages = [ pkgs.k3s ];

}