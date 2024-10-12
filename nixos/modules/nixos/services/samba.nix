{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.mySystem.services.samba;
in
{
  options.mySystem.services.samba = {
    enable = lib.mkEnableOption "samba";
    shares = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.samba-users = {};

    services.samba = {
      inherit (cfg) shares;

      enable = true;
      package = pkgs.samba;
      openFirewall = true;

      extraConfig = ''
        min protocol = SMB2
        workgroup = WORKGROUP

        browseable = yes
        guest ok = no
        guest account = nobody
        map to guest = bad user
        inherit acls = yes
        map acl inherit = yes
        valid users = @samba-users
      '';
    };
  };
}