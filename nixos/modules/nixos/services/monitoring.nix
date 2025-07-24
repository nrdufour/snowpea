{ lib
, config
, self
, ...
}:
with lib;
let
  cfg = config.mySystem.services.monitoring;
  exporterPort = 9002;
in
{
  options.mySystem.services.monitoring.enable = mkEnableOption "Prometheus Monitoring";

  config = mkIf cfg.enable {
    services.prometheus = {
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "diskstats"
            "filesystem"
            "loadavg"
            "meminfo"
            "netdev"
            "stat"
            "time"
            "uname"
            "systemd"
          ];
          port = exporterPort;
        };
        smartctl = {
          enable = true;
        };
      };
    };

    systemd.services."prometheus-smartctl-exporter".serviceConfig.DeviceAllow = lib.mkOverride 10 [
        "block-blkext rw"
        "block-sd rw"
        "char-nvme rw"
    ];

    services.udev.extraRules = ''
      SUBSYSTEM=="nvme", KERNEL=="nvme[0-9]*", GROUP="disk"
    '';

    networking.firewall = {
      allowedTCPPorts = [ exporterPort ];
    };
  };

}