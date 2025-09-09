{ 
  pkgs,
  config,
  ...
}:
let 
  image = "mbentley/omada-controller:latest";
in 
{

  users.users.omada = {
    home = "/var/lib/omada-controller";
    group = "omada";
    isSystemUser = true;
    uid = 1000;
  };

  users.groups.omada = {
    gid = 1000;
  };

  # Create directory for Omada Controller data
  systemd.tmpfiles.rules = [
    "d /var/lib/omada-controller/data 0755 omada omada -"
    "d /var/lib/omada-controller/logs 0755 omada omada -"
  ];

  virtualisation.oci-containers.containers."omada-controller" = {
    inherit image;
    volumes = [
      "/var/lib/omada-controller/data:/opt/tplink/EAPController/data"
      "/var/lib/omada-controller/logs:/opt/tplink/EAPController/logs"
    ];
    ports = [
      "8088:8088"   # Management HTTP
      "8043:8043"   # Management HTTPS
      "8843:8843"   # Portal HTTPS
      "27001:27001/udp"  # Discovery
      "27002:27002" # Controller-AP communication
      "29810:29810/udp"  # Discovery
      "29811:29811" # EAP Discovery
      "29812:29812" # Manager V1
      "29813:29813" # Manager V2
      "29814:29814" # Inform
      "29815:29815" # Device management
      "29816:29816" # Device management
      "19810:19810/udp" # Device management UDP
    ];
    environment = {
      MANAGE_HTTP_PORT = "8088";
      MANAGE_HTTPS_PORT = "8043";
      PORTAL_HTTP_PORT = "8088";
      PORTAL_HTTPS_PORT = "8843";
      SHOW_SERVER_LOGS = "true";
      SHOW_MONGODB_LOGS = "false";
      TZ = "America/New_York";
    };
    extraOptions = [
      # NixOS systemd handles restart policy, not the container
    ];
  };

  # Open firewall ports for Omada Controller - ONLY on internal interfaces
  networking.firewall.interfaces = {
    lan0.allowedTCPPorts = [
      8088  # Management HTTP
      8043  # Management HTTPS  
      8843  # Portal HTTPS
      27002 # Controller-AP communication
      29811 # EAP Discovery
      29812 # Manager V1
      29813 # Manager V2
      29814 # Inform
      29815 # Device management
      29816 # Device management
    ];
    lan0.allowedUDPPorts = [
      27001 # Discovery
      29810 # Discovery
      19810 # Device management
    ];
    
    lab0.allowedTCPPorts = [
      8088 8043 8843 27002 29811 29812 29813 29814 29815 29816
    ];
    lab0.allowedUDPPorts = [
      27001 29810 19810
    ];
    
    lab1.allowedTCPPorts = [
      8088 8043 8843 27002 29811 29812 29813 29814 29815 29816
    ];
    lab1.allowedUDPPorts = [
      27001 29810 19810
    ];
  };

}