{ lib, config, ... }: {

  imports = [
    ./security
    ./services
    ./system
  ];

  options.mySystem.nasFolder = mkOption {
    type = types.str;
    description = "folder where nas mounts reside";
    default = "/srv/storage";
  };
  options.mySystem.domain = mkOption {
    type = types.str;
    description = "domain for hosted services";
    default = "ptinem.casa";
  };
  options.mySystem.internalDomain = mkOption {
    type = types.str;
    description = "domain for local devices";
    default = "internal";
  };
}