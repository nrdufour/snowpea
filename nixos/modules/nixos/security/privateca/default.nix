{ lib
, config
, self
, ...
}:
with lib;
let
  cfg = config.mySystem.security.privateca;
in
{
  options.mySystem.security.privateca = {
    enable = mkEnableOption "privateca" // { default = true; };
  };

  config = mkIf cfg.enable {
    security.pki.certificates = [
      (builtins.readFile ./root_ca.crt)
    ];
  };
}
