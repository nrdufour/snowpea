{ ... }: {
  imports = [ ./. ];

  services.k3s.role = "server";

  services.k3s.extraFlags = toString [
    "--disable=local-storage"
    "--disable=traefik"
    "--disable=metrics-server"
  ];
}