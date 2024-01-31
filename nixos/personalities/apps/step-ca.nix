{ pkgs, ... }: {
  services.step-ca.enable = true;
  services.step-ca.intermediatePasswordFile = "/srv/storage/apps/step-ca/smallstep-password";
  services.step-ca.address = "0.0.0.0";
  services.step-ca.port = 8443;

  services.step-ca.settings = builtins.fromJSON(''
{
	"root": "/var/lib/step-ca/certs/root_ca.crt",
	"federatedRoots": null,
	"crt": "/var/lib/step-ca/certs/intermediate_ca.crt",
	"key": "/var/lib/step-ca/secrets/intermediate_ca_key",
	"address": ":8443",
	"insecureAddress": "",
	"dnsNames": [
		"localhost",
		"eagle.home",
		"myca.home"
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
}'');

  environment.systemPackages = with pkgs; [
    step-ca
		step-cli
  ];

	security.acme = {
		acceptTerms = true;
		defaults = {
			email = "nrdufour@gmail.com";
			server = "https://localhost:8443/acme/acme/directory";
			webroot = "/var/lib/acme/acme-challenge";
		};
	};

  networking.firewall.allowedTCPPorts = [ 8443 ];
}