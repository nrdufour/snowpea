{ ... }: {
  imports = [ ./. ];

  services.k3s.role = "server";
  services.k3s.serverAddr = "https://main-cp.internal:6443";

  services.k3s.extraFlags = toString [
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
  ];
}