{ pkgs, config, ... }: {

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./network.nix
      ./secrets.nix
      ./kea
      ./knot
      # ./bind
      ./firewall.nix
    ];

  networking.domain = "internal";

  services.openssh.openFirewall = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    dig
  ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "git+https://forge.internal/nemo/snowpea.git";
  };

}
