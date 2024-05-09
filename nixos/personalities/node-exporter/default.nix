let exporterPort = 9002;
in 
{
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
}