{ lib
, config
, pkgs
, ...
}:
let
  cfg = config.mySystem.system.zfs;
in
with lib;
{
  options.mySystem.system.zfs = {
    enable = lib.mkEnableOption "zfs";
    mountPoolsAtBoot = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

  };

  config = lib.mkIf cfg.enable {

    # setup boot
    boot = {
      supportedFilesystems = [
        "zfs"
      ];
      zfs = {
        forceImportRoot = false; # if stuck on boot, modify grub options , force importing isnt secure
        extraPools = cfg.mountPoolsAtBoot;
      };


    };

    services.zfs = {
      autoScrub.enable = true;
      # Defaults to weekly and is a bit too regular for my NAS
      autoScrub.interval = "monthly";
      trim.enable = true;
    };

    services.prometheus.exporters.zfs.enable = true;

  };
}