{ pkgs, config, ... }: {

  networking.hostName = "beacon";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9c9cb9f0-75d9-46f0-9113-4dbf36a3371f";
      fsType = "ext4";
    };

  swapDevices = [ ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "beacon.internal" = {
        locations."/".proxyPass = "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };
}
