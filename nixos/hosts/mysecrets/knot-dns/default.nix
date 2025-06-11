{
  pkgs,
  ...
}: {
  # imports = [
  # ];

  services.knot = {
    enable = true;
  };
}