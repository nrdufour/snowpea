{ lib, pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-linux";
  nix.settings.trusted-users = [ "@wheel" ];
  system.stateVersion = "23.11";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  sdImage = {
    # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low on space.
    compressImage = false;

    # imageName = "pi4.img";
  };

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  # Useful for container support
  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "console=ttyAMA0,115200n8"
    "console=tty0"
    "cgroup_enable=cpuset"
    "cgroup_memory=1"
    "cgroup_enable=memory"
  ];

  # Make sure the ethernet interface is using dhcp
  networking = {
    interfaces."end0".useDHCP = true;
  };

  environment.systemPackages = with pkgs; [
    neofetch
    vim
  ];

  # Ensure ssh is up
  services.sshd.enable = true;

  # NTP time sync
  services.timesyncd.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  time.timeZone = "America/New_York";
}
