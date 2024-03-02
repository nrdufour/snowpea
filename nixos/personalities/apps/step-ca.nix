{ config, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    step-ca
		step-cli
  ];

  sops.secrets.stepca_intermediate_password = {
    sopsFile = ../../../secrets/mysecrets/secrets.sops.yaml;
  };

	services.step-ca = {
		enable = true;
		intermediatePasswordFile = config.sops.secrets.stepca_intermediate_password.path;
		address = "0.0.0.0";
		port = 8443;
		openFirewall = true;
	};

  services.step-ca.settings = builtins.fromJSON(
		''
		{
			"root": "/var/lib/step-ca/certs/root_ca.crt",
			"federatedRoots": null,
			"crt": "/var/lib/step-ca/certs/intermediate_ca.crt",
			"key": "/var/lib/step-ca/secrets/intermediate_ca_key",
			"address": ":8443",
			"insecureAddress": "",
			"dnsNames": [
				"localhost",
				"mysecrets.home.arpa",
				"mysecrets.internal"
			],
			"logger": {
				"format": "text"
			},
			"db": {
				"type": "badgerv2",
				"dataSource": "/var/lib/step-ca/db",
				"badgerFileLoadingMode": ""
			},
			"authority": {
				"provisioners": [
					{
						"type": "ACME",
						"name": "acme"
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
		''
	);

}