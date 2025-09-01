{
  config,
  pkgs,
  ...
}: {

  services.adguardhome = {
    enable = true;

    host = "127.0.0.1";
    port = 3003;

    settings = {
      http = {
        address = "127.0.0.1:3003";
      };
      dns = {
        bind_hosts = [
          "10.0.0.54"
          "10.1.0.54"
          # "10.2.0.54"
        ];
        upstream_dns = [
          "10.0.0.1"
        ];
        ipv6 = false;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      # filters = map(url: { enabled = true; url = url; }) [
      #   "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
      #   "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
      # ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;

    virtualHosts."adguard.internal" = {
      serverName = "adguard.internal";
      extraConfig = ''
        client_max_body_size 2g;
      '';
      locations."/".proxyPass = "http://localhost:3003";
    };
  };

}