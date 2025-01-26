{
  lib,
  config,
  nixpkgs,
  pkgs,
  ...
}:
{
  boot = {
    initrd.availableKernelModules = [ "ohci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];

    # Switching to 6.12 as well
    kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}