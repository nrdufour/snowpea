{ config, lib, pkgs, ... }:
let
  cfg = config.services.step-ca;
  settingsFormat = (pkgs.formats.json { });
in
{
  meta.maintainers = with lib.maintainers; [ mohe2015 ];

  #
  # Custom chage from the nixpkgs modules:
  # 1) able to specify the user directory (default /var/lib/step-ca) [done]
  # 2) find a way to templatize the ca.json file for secret [todo]
  # 3) disable the password for now, need a cleaner way
  #

  options = {
    services.step-ca = {
      enable = lib.mkEnableOption (lib.mdDoc "the smallstep certificate authority server");
      openFirewall = lib.mkEnableOption (lib.mdDoc "opening the certificate authority server port");
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.step-ca;
        defaultText = lib.literalExpression "pkgs.step-ca";
        description = lib.mdDoc "Which step-ca package to use.";
      };
      address = lib.mkOption {
        type = lib.types.str;
        example = "127.0.0.1";
        description = lib.mdDoc ''
          The address (without port) the certificate authority should listen at.
          This combined with {option}`services.step-ca.port` overrides {option}`services.step-ca.settings.address`.
        '';
      };
      port = lib.mkOption {
        type = lib.types.port;
        example = 8443;
        description = lib.mdDoc ''
          The port the certificate authority should listen on.
          This combined with {option}`services.step-ca.address` overrides {option}`services.step-ca.settings.address`.
        '';
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = lib.mdDoc ''
          Settings that go into {file}`ca.json`. See
          [the step-ca manual](https://smallstep.com/docs/step-ca/configuration)
          for more information. The easiest way to
          configure this module would be to run `step ca init`
          to generate {file}`ca.json` and then import it using
          `builtins.fromJSON`.
          [This article](https://smallstep.com/docs/step-cli/basic-crypto-operations#run-an-offline-x509-certificate-authority)
          may also be useful if you want to customize certain aspects of
          certificate generation for your CA.
          You need to change the database storage path to {file}`/var/lib/step-ca/db`.

          ::: {.warning}
          The {option}`services.step-ca.settings.address` option
          will be ignored and overwritten by
          {option}`services.step-ca.address` and
          {option}`services.step-ca.port`.
          :::
        '';
      };
      settingsFile = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = lib.mdDoc ''
          Path to the file containing the configuration.

          ::: {.warning}
          Make sure to use a quoted absolute path instead of a path literal
          to prevent it from being copied to the globally readable Nix
          store.
          :::
        '';
      };
      intermediatePasswordFile = lib.mkOption {
        type = lib.types.path;
        example = "/run/keys/smallstep-password";
        description = lib.mdDoc ''
          Path to the file containing the password for the intermediate
          certificate private key.

          ::: {.warning}
          Make sure to use a quoted absolute path instead of a path literal
          to prevent it from being copied to the globally readable Nix
          store.
          :::
        '';
      };
      userDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/step-ca";
        description = lib.mdDoc ''
          The directory in which the step-ca user will be created.
        '';
      };
    };
  };

  config = lib.mkIf config.services.step-ca.enable (
    let
      configFile =
        if cfg.settingsFile != ""
          then cfg.settingsFile
          else settingsFormat.generate "ca.json" (cfg.settings // {
            address = cfg.address + ":" + toString cfg.port;
          });
    in
    {
      assertions =
        [
          {
            assertion = !lib.isStorePath cfg.intermediatePasswordFile;
            message = ''
              <option>services.step-ca.intermediatePasswordFile</option> points to
              a file in the Nix store. You should use a quoted absolute path to
              prevent this.
            '';
          }
          {
            assertion = !lib.isStorePath cfg.settingsFile;
            message = ''
              <option>services.step-ca.settingsFile</option> points to
              a file in the Nix store. You should use a quoted absolute path to
              prevent this.
            '';
          }
        ];

      systemd.packages = [ cfg.package ];

      # configuration file indirection is needed to support reloading
      environment.etc."smallstep/ca.json".source = configFile;

      systemd.services."step-ca" = {
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ configFile ];
        unitConfig = {
          ConditionFileNotEmpty = ""; # override upstream
        };
        serviceConfig = {
          User = "step-ca";
          Group = "step-ca";
          UMask = "0077";
          Environment = "HOME=${cfg.userDir}";
          WorkingDirectory = ""; # override upstream
          ReadWriteDirectories = ""; # override upstream
          ReadWritePaths = "${cfg.userDir}/db";

          # LocalCredential handles file permission problems arising from the use of DynamicUser.
          LoadCredential = "intermediate_password:${cfg.intermediatePasswordFile}";

          ExecStart = [
            "" # override upstream
            "${cfg.package}/bin/step-ca ${configFile} --password-file \${CREDENTIALS_DIRECTORY}/intermediate_password"
          ];

          # ProtectProc = "invisible"; # not supported by upstream yet
          # ProcSubset = "pid"; # not supported by upstream yet
          # PrivateUsers = true; # doesn't work with privileged ports therefore not supported by upstream

          DynamicUser = true;
          StateDirectory = "step-ca";
        };
      };

      users.users.step-ca = {
        home = cfg.userDir;
        group = "step-ca";
        isSystemUser = true;
      };

      users.groups.step-ca = {};

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [ cfg.port ];
      };
    }
  );
}