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
      enable = true;
      package = pkgs.samba;
      openFirewall = true;

      settings = {
        global = {
          "invalid users" = [
            "root"
          ];
          "passwd program" = "/run/wrappers/bin/passwd %u";
          security = "user";

          ## previous extraConfig comes here
          "min protocol" = "SMB2";
          workgroup = "WORKGROUP";

          browseable = "yes"; 
          "guest ok" = "no";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "inherit acls" = "yes";
          "map acl inherits" = "yes";
          "valid users" = "@samba-users";
        };
      } // cfg.shares;
    };
  };
}