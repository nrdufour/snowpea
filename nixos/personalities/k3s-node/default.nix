{ config, pkgs, lib, ... }: {

  config = {
    services.k3s.enable = true;
    services.k3s.package = pkgs.unstable.k3s_1_28;
    environment.systemPackages = [ pkgs.unstable.k3s_1_28 ];

    # For NFS
    boot.supportedFilesystems = [ "nfs" ];
    services.rpcbind.enable = true;

    # Token
    sops.secrets.k3s-server-token = {};
    services.k3s.tokenFile = lib.mkDefault config.sops.secrets.k3s-server-token.path;
  };
}