{ config, pkgs, lib, ... }: {

  config = {
    # Token
    sops.secrets.k3s-server-token = { };

    services.k3s = {
      enable = true;
      package = pkgs.unstable.k3s_1_28;
      tokenFile = lib.mkDefault config.sops.secrets.k3s-server-token.path;
    };
    environment.systemPackages = [ pkgs.unstable.k3s_1_28 ];

    # For NFS
    boot.supportedFilesystems = [ "nfs" ];
    services.rpcbind.enable = true;
  };
}
