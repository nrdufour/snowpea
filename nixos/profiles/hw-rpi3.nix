{
  config,
  lib,
  pkgs,
  imports,
  boot,
  nixpkgs,
  ...
}:

with lib;
{
  imports = [
    ./hw-sdcard.nix
  ];

  boot = {

    initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
      timeout = 2;
    };
  };

  nixpkgs.hostPlatform.system = "aarch64-linux";

  # No point keeping this for now...
  # console.enable = false;

  # Disable bluetooth
  hardware.bluetooth.enable = false;
  hardware.bluetooth.powerOnBoot = false;
  boot.blacklistedKernelModules = [ "bluetooth" ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Useful for container support
  boot.kernelParams = [
    "cgroup_enable=cpuset"
    "cgroup_memory=1"
    "cgroup_enable=memory"
  ];

}