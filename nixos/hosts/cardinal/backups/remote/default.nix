{
  config,
  pkgs,
  ...
}:
{
  # Remote backups into S3 bucket

  imports =
    [
      ./rclone-books-remote.nix
    ];

  environment.systemPackages = with pkgs; [
    rclone
  ];

  sops.secrets = {
    "backups/remote-s3/access-key" = {
      sopsFile = ../../../../../secrets/common-remote-restic/secrets.sops.yaml;  
    };
    "backups/remote-s3/secret-key" = {
      sopsFile = ../../../../../secrets/common-remote-restic/secrets.sops.yaml;
    };
  };

  sops.templates."rclone-remote-access.conf" = {
    owner = "root";
    content = ''
      [scaleway]
      type = s3
      provider = Scaleway
      access_key_id = ${config.sops.placeholder."backups/remote-s3/access-key"}
      secret_access_key = ${config.sops.placeholder."backups/remote-s3/secret-key"}
      region = fr-par
      endpoint = s3.fr-par.scw.cloud
    '';
  };
}