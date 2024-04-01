{ config, pkgs, lib, ... }: {

  config = {
    services.k3s.enable = true;
    environment.systemPackages = [ pkgs.k3s ];

    # For NFS
    boot.supportedFilesystems = [ "nfs" ];
    services.rpcbind.enable = true;

    # Token
    sops.secrets.k3s-server-token = {};
    services.k3s.tokenFile = lib.mkDefault config.sops.secrets.k3s-server-token.path;
  };
}