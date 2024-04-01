{ config, lib, ... }: {
  imports = [ ./. ];

  services.k3s.role = "agent";
  services.k3s.serverAddr = "https://main-cp.internal:6443";
}