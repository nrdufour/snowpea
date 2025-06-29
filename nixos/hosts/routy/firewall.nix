{
  networking.firewall = {
    enable = true;
    trustedInterfaces = [
      "lan0"
      "lab0"
      "lan1"
      "lan0.20"
      "lan0.50"
      "lan0.100"
     ];
    interfaces = {
      wan = {
        allowedTCPPorts = [
          22
        ];
        allowedUDPPorts = [
        ];
      };
    };
  };
}