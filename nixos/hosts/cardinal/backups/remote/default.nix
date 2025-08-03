{
  config,
  pkgs,
  ...
}:
{
  # Remote backups into B2

  imports =
    [
      ./rclone-books-remote.nix
    ];

  environment.systemPackages = with pkgs; [
    rclone
  ];

  sops.secrets = {
    "backups/b2/account" = {
      sopsFile = ../../../../../secrets/common-remote-restic/secrets.sops.yaml;
    };
    "backups/b2/key" = {
      sopsFile = ../../../../../secrets/common-remote-restic/secrets.sops.yaml;
    };
  };

  sops.templates."rclone-remote-access.conf" = {
    owner = "root";
    content = ''
      [b2]
      type = b2
      account = ${config.sops.placeholder."backups/b2/account"}
      key = ${config.sops.placeholder."backups/b2/key"}
      hard_delete = true
    '';
  };
}