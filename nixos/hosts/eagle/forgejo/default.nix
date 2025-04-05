{
  pkgs,
  ...
}: {
  imports = [
    ./local-pg.nix
    ./forgejo.nix
    ./forgejo-runner.nix
    ./forgejo-rclone.nix
    ./forgejo-restic-remote.nix
  ];
}