{ lib, config, ... }: {

  imports = [
    ./security
    ./services
    ./system
  ];

  options.mySystem.domain = lib.mkOption {
    type = lib.types.str;
    description = "domain for hosted services";
    default = "ptinem.casa";
  };
  options.mySystem.internalDomain = lib.mkOption {
    type = lib.types.str;
    description = "domain for local devices";
    default = "internal";
  };
}