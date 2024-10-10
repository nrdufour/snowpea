{ pkgs, lib, config, self, ... }:
with lib;
let
  cfg = config.mySystem.services.k3s;
  defaultServerAddr = "https://main-cp.internal:6443";
  ## Kubernetes versions in stable:
  ## k3s: 1.30
  ## k3s_1_29: 1.29
  ## and so on
  k3sPackage = pkgs.k3s_1_31;
in
{
  options.mySystem.services.k3s = {
    enable = mkEnableOption "k3s";

    additionalFlags = mkOption {
      description = "Additional flags added to the k3s service as arguments";
      default = "";
      type = types.str;
    };

    role = mkOption {
      description = ''
        Whether k3s should run as a server or agent.

        If it's a server:

        - By default it also runs workloads as an agent.
        - Starts by default as a standalone server using an embedded sqlite datastore.
        - Configure `clusterInit = true` to switch over to embedded etcd datastore and enable HA mode.
        - Configure `serverAddr` to join an already-initialized HA cluster.

        If it's an agent:

        - `serverAddr` is required.
      '';
      default = "server";
      type = types.enum [
        "server"
        "agent"
      ];
    };

    isClusterInit = mkOption {
      description = "true if this is the first controller";
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # Token
    sops.secrets.k3s-server-token = { };

    services.k3s = {
      enable = true;
      package = k3sPackage;
      tokenFile = lib.mkDefault config.sops.secrets.k3s-server-token.path;
      serverAddr = defaultServerAddr;
      inherit (cfg) role;
      clusterInit = cfg.isClusterInit;
      extraFlags = (if cfg.role == "agent"
        then ""
        else toString [
          # Disable useless services
          ## TODO: probably need to add service-lb soon
          "--disable=local-storage"
          "--disable=traefik"
          "--disable=metrics-server"
          # virtual IP and its name
          "--tls-san main-cp.internal"
          "--tls-san 192.168.20.250"
          # Components extra args
          "--kube-apiserver-arg default-not-ready-toleration-seconds=20"
          "--kube-apiserver-arg default-unreachable-toleration-seconds=20"
          "--kube-controller-manager-arg bind-address=0.0.0.0"
          "--kube-controller-manager-arg node-monitor-period=4s"
          "--kube-controller-manager-arg node-monitor-grace-period=16s"
          "--kube-proxy-arg metrics-bind-address=0.0.0.0"
          "--kube-scheduler-arg bind-address=0.0.0.0"
          "--kubelet-arg node-status-update-frequency=4s"
          # Others
          "--etcd-expose-metrics"
          "--disable-cloud-controller"
        ]) + cfg.additionalFlags;
    };
    environment.systemPackages = [
      k3sPackage

      # For NFS
      pkgs.nfs-utils
      # For open-iscsi
      pkgs.openiscsi
    ];

    # For NFS
    boot.supportedFilesystems = [ "nfs" ];
    services.rpcbind.enable = true;

    # For open-iscsi
    services.openiscsi = {
      enable = true;
      name = "iqn.2005-10.nixos:${config.networking.hostName}";
    };
  };

}