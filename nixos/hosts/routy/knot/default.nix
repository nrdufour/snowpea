{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./dns.nix
    ./resolver.nix
  ];
}