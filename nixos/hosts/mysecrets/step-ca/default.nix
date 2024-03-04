{ config, pkgs, lib, ... }: {

	disabledModules = [ "services/security/step-ca.nix" ];

  imports = [
    ../../../modules/step-ca.nix
  ];

  # Using a yubikey to store the keypairs
  environment.systemPackages = with pkgs; [
    yubikey-manager
    step-ca
		step-cli
  ];
  services.pcscd.enable = true;

  sops.secrets = {
    stepca_intermediate_password = {};
    stepca_yubikey_pin = {};
  };

  environment.etc."smallstep/root_ca.crt" = {
    text = lib.readFile ./resources/root_ca.crt;
    user = "step-ca";
  };

  environment.etc."smallstep/intermediate_ca.crt" = {
    text = lib.readFile ./resources/intermediate_ca.crt;
    user = "step-ca";
  };

	sops.templates."smallstep-config.json" = {
    owner = "step-ca";
    content = ''
      {
      "root": "/etc/smallstep/root_ca.crt",
      "crt": "/etc/smallstep/intermediate_ca.crt",
      "key": "yubikey:slot-id=9c",
      "kms": {
        "type": "yubikey",
        "pin": "${config.sops.placeholder.stepca_yubikey_pin}"
      },
      "address": "${config.services.step-ca.address}:${toString config.services.step-ca.port}",
      "insecureAddress": "",
      "dnsNames": [
        "myca.internal",
        "myca.home.arpa",
        "192.168.20.99"
      ],
      "logger": {
        "format": "text"
      },
      "db": {
        "type": "badgerv2",
        "dataSource": "${config.services.step-ca.userDir}",
        "badgerFileLoadingMode": ""
      },
      "authority": {
        "enableAdmin": true,
        "provisioners": [
          {
            "name": "acme",
            "type": "ACME"
          }
        ]
      },
      "tls": {
        "cipherSuites": [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ],
        "minVersion": 1.2,
        "maxVersion": 1.3,
        "renegotiation": false
      }
    }
    '';
  };

	services.step-ca = {
		enable = true;
		intermediatePasswordFile = config.sops.secrets.stepca_intermediate_password.path;
		address = "0.0.0.0";
		port = 8443;
		openFirewall = true;

		# From custom module
		settingsFile = config.sops.templates."smallstep-config.json".path;
	};

}