{
  config,
  pkgs,
  ...
}: {
  # imports = [
  # ];

  services.kresd = {
    enable = true;

    listenPlain = [
      "[::1]:53"
      "127.0.0.1:53"
      "10.0.0.1:53"
      "10.1.0.1:53"
      "10.2.0.1:53"
    ];

    extraConfig = ''
      log_level('debug')

      -- define list of internal-only domains
      internalDomains = policy.todnames({'internal'})

      -- forward all queries belonging to domains in the list above to IP address '10.0.0.53'
      policy.add(policy.suffix(policy.FLAGS({'NO_CACHE'}), internalDomains))
      policy.add(policy.suffix(policy.STUB({'10.0.0.53'}), internalDomains))
    '';
  };
}