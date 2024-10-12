{
  imports = [
    ./monitoring.nix
    ./reboot-required-check.nix
    ./k3s
    ./nfs.nix
    ./minio.nix
    ./samba.nix
  ];
}