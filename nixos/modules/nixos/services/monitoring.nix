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
          enabledCollectors = [ "systemd" ];
          port = exporterPort;
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [ exporterPort ];
    };
  };

}